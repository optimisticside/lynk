-- Lynk layout
-- OptimisticSide
-- 12/20/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

local Layout = {}

-- Shared modules - ReplicatedStorage/Shared
Layout.shared = ReplicatedStorage:WaitForChild("Shared")

if isServer then
    -- Server services - ServerStorage/Services
    Layout.services = ServerStorage:WaitForChild("Services")
    -- Server modules - ServerStorage/Modules
    Layout.modules = ServerStorage:WaitForChild("Modules")
else
    local localPlayer = Players.LocalPlayer
    local playerScripts = localPlayer:WaitForChild("PlayerScripts")

    -- Client controllers - PlayerScripts/Controllers
    Layout.controllers = playerScripts:WaitForChild("Controllers")
    -- Client modules - PlayerScripts/Modules
    Layout.modules = playerScripts:WaitForChild("Modules")
end

return Layout