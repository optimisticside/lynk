-- Lynx server framework
-- OptimisticSide
-- 12/20/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local LynkApi = require(ReplicatedStorage.Lynk)
local Layout = LynkApi:getLayout()

local serverServices = Layout.services
local serverModules = Layout.modules

local sharedModules = Layout.shared

local Server = LynkApi:getFramework() or {
    startTime = os.clock(),
    services = {},
    modules = {},
    shared = {},
}

function Server:requireModule(module: ModuleScript, name: string?): any
    -- require the module in a protected thread
    local didRequire, result = pcall(require, module)

    -- if successful
    if didRequire then
        -- return required module
        return result
    end

    -- error
    error(string.format("Unable to load module \"%s\": %s", name or "[Unknown]", result))
end

function Server:createService(name: string, initialData: ModuleScript | table?): table
    -- if module isn't a table
    if typeof(initialData) ~= "table" then
        initialData = self:requireModule(initialData, name)
    end

    -- wrap service
    local service = self:wrap(initialData, name) or {}

    -- add to services and return
    self.services[name] = service
    return self.services[name]
end

function Server:createModule(name: string, initialData: ModuleScript | table?): table
    -- if module isn't a table
    if typeof(initialData) ~= "table" then
        initialData = self:requireModule(initialData, name)
    end

    -- wrap module
    local module = self:wrap(initialData, name) or {}

    -- add to modules and return
    self.modules[name] = module
    return self.modules[name]
end

function Server:createShared(name: string, initialData: ModuleScript | table?): table
    -- if module isn't a table
    if typeof(initialData) ~= "table" then
        initialData = self:requireModule(initialData, name)
    end

    -- wrap module
    local module = self:wrap(initialData, name) or {}

    -- add to shared and return
    self.shared[name] = module
    return self.shared[name]
end

function Server:initModule(module: table?): nil
    -- make sure module is a table
    if typeof(module) ~= "table" then
        return
    end

    -- check if init exists
    if rawget(module, "init") and not rawget(module, "disableInit") then
        -- execute init function
        module:init()
    end
end

function Server:getUptime()
    return os.clock() - self.startTime
end

function Server:startModule(module: table?): nil
    -- make sure module is a table
    if typeof(module) ~= "table" then
        return
    end
    -- check if start exists
    if rawget(module, "start") and not rawget(module, "disableStart") then
        -- create a bindable event to connect to and execute start function
        -- more reliable as opposed to spawn function
        local spawner = Instance.new("BindableEvent")

        -- connect to event
        spawner.Event:Connect(function()
            -- execute start function
            module:start()
        end)

        -- fire and destroy bindable event
        spawner:Fire()
        spawner:Destroy()
    end
end

function Server:wrap(rawTable: table, name: string?): table
    if typeof(rawTable) ~= "table" then
        return rawTable
    end

    local baseTable = {moduleName = name}
    local metaTable = {}

    function baseTable:isWrapped()
        return true
    end
    function baseTable:getFramework()
        return self
    end

    function metaTable.__index(module: table, index: string): any
        --[[local result

        -- trying to access a member of the module
        if rawTable[index] then
            result = rawTable[index]

        -- trying to access member of framework
        else
            result = self[index]
        end

        -- return result
        return result]]
        return self[index]
    end

    --[[function metaTable.__newindex(module: table, index: string, value: any): nil
        rawTable[index] = value
    end]]

    for index, element in pairs(rawTable) do
        baseTable[index] = element
    end

    setmetatable(baseTable, metaTable)
    return baseTable
end

function Server:setup()
    -- setup existing modules
    for _, serverModule in ipairs(serverModules:GetChildren()) do
        self:createModule(serverModule.Name, serverModule)
    end

    -- setup existing services
    for _, serverService in ipairs(serverServices:GetChildren()) do
        self:createService(serverService.Name, serverService)
    end

    -- setup existing shared modules
    for _, sharedModule in ipairs(sharedModules:GetChildren()) do
        self:createShared(sharedModule.Name, sharedModule)
    end

    -- setup upon module add
    serverModules.ChildAdded:Connect(function(serverModule)
        self:createModule(serverModule.Name, serverModule)
    end)

    -- setup upon service add
    serverServices.ChildAdded:Connect(function(serverService)
        self:createService(serverService.Name, serverService)
    end)

    -- setup upon shared add
    sharedModules.ChildAdded:Connect(function(sharedModule)
        self:createShared(sharedModules.Name, sharedModule)
    end)
end

function Server:start()
    -- initialize all modules
    for name, module in pairs(self.modules) do
        self:initModule(module)
    end

    -- initialize all services
    for name, service in pairs(self.services) do
        self:initModule(service)
    end

    -- initialize all shared modules
    for name, module in pairs(self.shared) do
        self:initModule(module)
    end

    -- start all modules
    for name, module in pairs(self.modules) do
        self:startModule(module)
    end

    -- start all services
    for name, service in pairs(self.services) do
        self:startModule(service)
    end

    -- start all shared modules
    for name, module in pairs(self.shared) do
        self:startModule(module)
    end
end

function Server:init()
    self:setup()
    self:start()

    -- set global variable for external refrence
    LynkApi:registerFramework(self)
end

-- initialize if not module-script
if not script:IsA("ModuleScript") then
    return Server:init()
end

-- if module-script, return main table
return Server