-- Network
-- OptimisticSIde
-- 12/21/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local isServer = RunService:IsServer()

local Network = {}

function Network:fireClient(remoteName: string, client: Player, ...): nil
    local remote = self.remoteEvents[remoteName]

    if remote then
        remote:FireClient(client, ...)
    end
end

function Network:fireClients(remoteName: string, clients: table, ...): nil
    local remote = self.remoteEvents[remoteName]

    if remote then
        for _, client in ipairs(clients) do
            remote:FireClient(client, ...)
        end
    end
end

function Network:fireAllClients(remoteName: string, ...): nil
    local remote = self.remoteEvents[remoteName]

    if remote then
        self:fireClients(remoteName, Players:GetPlayers(), ...)
    end
end

function Network:fireOtherClients(remoteName: string, omit: Player, ...): table
    local clients = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= omit then
            clients[#clients+1] = player
        end
    end

    return self:fireClients(remoteName, clients, ...)
end

function Network:invokeClient(remoteName: string, client: Player, ...): tuple
    local remote = self.remoteFunctions[remoteName]

    if remote then
        return remote:InvokeClient(client, ...)
    end
end

function Network:invokeClients(remoteName: string, clients: table, ...): table
    local remote = self.remoteFunctions[remoteName]
    local responses = {}

    if remote then
        for _, client in ipairs(clients) do
            responses[client] = {remote:InvokeClient(client, ...)}
        end
    end

    return responses
end

function Network:invokeAllClients(remoteName: string, ...): table
    local remote = self.remoteFunctions[remoteName]

    if remote then
        return self:invokeClients(remoteName, Players:GetPlayers(), ...)
    end
end

function Network:invokeOtherClients(remoteName: string, omit: Player, ...): table
    local clients = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= omit then
            clients[#clients+1] = player
        end
    end

    return self:invokeClient(remoteName, clients, ...)
end

function Network:fireServer(remoteName: string, ...): nil
    local remote = self.remoteEvents[remoteName]

    if remote then
        remote:FireServer(...)
    end
end

function Network:invokeServer(remoteName: string, ...): tuple
    local remote = self.remoteFunctions[remoteName]

    if remote then
        return remote:InvokeServer(...)
    end
end

function Network:setupEvent(remoteEvent: RemoteEvent): nil
    self.eventConnections[remoteEvent.Name] = remoteEvent[isServer and "OnServerEvent" or "OnClientEvent"]:Connect(function(...)
        for callbackId, callback in pairs(self.eventCallbacks[remoteEvent.Name] or {}) do
            if callback then
                callback(...)
            end
        end
    end)
end

function Network:setupFunction(remoteFunction: RemoteFunction): nil
    remoteFunction[isServer and "OnServerInvoke" or "OnClientInvoke"] = function(...)
        for callbackId, callback in pairs(self.functionCallbacks[remoteFunction.Name] or {}) do
            if callback then
                local response = table.pack(callback(...))

                if #response > 0 then
                    return table.unpack(response)
                end
            end
        end
    end
end

function Network:bindToEvent(remoteName: string, func: callback): table
    self.eventCallbacks[remoteName] = self.eventCallbacks[remoteName] or {}
    local callbacks = self.eventCallbacks[remoteName]

    local callbackId = #callbacks + 1
    callbacks[callbackId] = func

    return {
        remoteName = remoteName,
        callbackId = callbackId,

        unbind = function(this)
            return self:unbindFromEvent(this)
        end
    }
end

function Network:bindToFunction(remoteName: string, func: callback): table
    self.functionCallbacks[remoteName] = self.functionCallbacks[remoteName] or {}
    local callbacks = self.functionCallbacks[remoteName]

    local callbackId = #callbacks + 1
    callbacks[callbackId] = func

    return {
        remoteName = remoteName,
        callbackId = callbackId,

        unbind = function(this)
            return self:unbindFromEvent(this)
        end
    }
end

function Network:unbindFromEvent(data: table): nil
    local callbacks = self.eventCallbacks[data.remoteName]

    if callbacks then
        callbacks[data.callbackId] = nil
    end
end

function Network:unbindFromFunction(data: table): nil
    local callbacks = self.functionCallbacks[data.remoteName]

    if callbacks then
        callbacks[data.callbackId] = nil
    end
end

function Network:setupChild(child: Instance): nil
    print("setting up", child)
    local className = child.ClassName

    if className == "RemoteEvent" then
        self.remoteEvents[child.Name] = child
        self:setupEvent(child)
        --self.eventCallbacks[child.Name] = {}

    elseif className == "RemoteFunction" then
        self.remoteFunctions[child.Name] = child
        self:setupFunction(child)
        --self.eventCallbacks[child.Name] = {}
    end
end

function Network:init(): nil
    self.remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

    self.remoteEvents = {}
    self.remoteFunctions = {}

    self.eventConnections = {}

    self.eventCallbacks = {}
    self.functionCallbacks = {}

    self.remotesFolder.DescendantAdded:Connect(function(...)
        self:setupChild(...)
    end)

    for _, descendant in ipairs(self.remotesFolder:GetDescendants()) do
        self:setupChild(descendant)
    end
end

return Network