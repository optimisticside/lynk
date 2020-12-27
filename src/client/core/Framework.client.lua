-- Lynx client framework
-- OptimisticSide
-- 12/20/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LynkApi = require(ReplicatedStorage:WaitForChild("Lynk"))
local Layout = LynkApi:getLayout()

local clientControllers = Layout.controllers
local clientModules = Layout.modules

local sharedModules = Layout.shared

local Client = LynkApi:getFramework() or {
    startTime = os.clock(),
    controllers = {},
    modules = {},
    shared = {},
}

function Client:requireModule(module: ModuleScript, name: string?): any
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

function Client:createController(name: string, initialData: ModuleScript | table?): table
    -- if module isn't a table
    if typeof(initialData) ~= "table" then
        initialData = self:requireModule(initialData, name)
    end

    -- wrap controller
    local controller = self:wrap(initialData, name) or {}

    -- add to controller and return
    self.controllers[name] = controller
    return self.controllers[name]
end

function Client:createModule(name: string, initialData: ModuleScript | table?): table
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

function Client:createShared(name: string, initialData: ModuleScript | table?): table
    -- if module
    if typeof(initialData) ~= "table" then
        initialData = self:requireModule(initialData, name)
    end

    -- wrap module
    local module = self:wrap(initialData, name) or {}

    -- add to shared and return
    self.shared[name] = module
    return self.shared[name]
end

function Client:initModule(module: table?): nil
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

function Client:getUptime()
    return os.clock() - self.startTime
end

function Client:startModule(module: table?): nil
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

function Client:wrap(rawTable: table, name: string?): table
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

function Client:setup()
    -- setup existing modules
    for _, clientModule in ipairs(clientModules:GetChildren()) do
        self:createModule(clientModule.Name, clientModule)
    end

    -- setup existing controllers
    for _, clientController in ipairs(clientControllers:GetChildren()) do
        self:createController(clientController.Name, clientController)
    end

    -- setup existing shared modules
    for _, sharedModule in ipairs(sharedModules:GetChildren()) do
        self:createShared(sharedModule.Name, sharedModule)
    end

    -- setup upon module add
    clientModules.ChildAdded:Connect(function(clientModule)
        self:createModule(clientModule.Name, clientModule)
    end)

    -- setup upon controller add
    clientControllers.ChildAdded:Connect(function(clientModule)
        self:createController(clientModule.Name, clientModule)
    end)

    -- setup upon shared add
    sharedModules.ChildAdded:Connect(function(sharedModule)
        self:createShared(sharedModules.Name, sharedModule)
    end)
end

function Client:start()
    -- initialize all modules
    for name, module in pairs(self.modules) do
        self:initModule(module)
    end

    -- initialize all controllers
    for name, controller in pairs(self.controllers) do
        self:initModule(controller)
    end

    -- initialize all shared modules
    for name, module in pairs(self.shared) do
        self:initModule(module)
    end

    -- start all modules
    for name, module in pairs(self.modules) do
        self:startModule(module)
    end

    -- start all controllers
    for name, controller in pairs(self.controllers) do
        self:startModule(controller)
    end

    -- start all shared modules
    for name, module in pairs(self.shared) do
        self:startModule(module)
    end
end

function Client:init()
    self:setup()
    self:start()

    -- set global variable for external refrence
    LynkApi:registerFramework(self)
end

-- initialize if not module-script
if not script:IsA("ModuleScript") then
    return Client:init()
end

-- if module-script, return main table
return Client