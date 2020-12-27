-- Lynk layout
-- OptimisticSide
-- 12/20/2020

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

local Layout = {}

Layout.shared = ReplicatedStorage:WaitForChild("Shared")

if isServer then
    Layout.services = ServerStorage:WaitForChild("Services")
    Layout.modules = ServerStorage:WaitForChild("Modules")
else
    local localPlayer = Players.LocalPlayer
    local playerScripts = localPlayer:WaitForChild("PlayerScripts")

    Layout.controllers = playerScripts:WaitForChild("Controllers")
    Layout.modules = playerScripts:WaitForChild("Modules")
end

return Layout