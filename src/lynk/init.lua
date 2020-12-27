-- Lynk API
-- OptimisticSide
-- 12/20/2020

local RunService = game:GetService("RunService")

local Layout = require(script.Layout)

local Lynk = {}

function Lynk:frameworkExists()
    return _G.Lynk ~= nil
end

function Lynk:getFramework()
    return _G.Lynk
end

function Lynk:registerFramework(framework: table): nil
    _G.Lynk = framework
end

function Lynk:getLayout()
    return Layout
end

function Lynk:isServer()
    return RunService:IsServer()
end

function Lynk:isClient()
    return RunService:IsClient()
end

function Lynk:isStudio()
    return RunService:IsStudio()
end

return Lynk