<p align="center"><img src="https://raw.githubusercontent.com/optimisticside/lynk/master/assets/logo.png" width="40%" height="40%"></p>

Lynk is an adaptable framework for development on the Roblox platform, and is heavily inspired by Sleitnick's [AeroGameFramework](https://github.com/Sleitnick/AeroGameFramework/tree/master/src). Lynk provides only the bare-bones of a framework, and does not include any network handling like AGF. Although, an additional `Network` is provided by default (but is not required).

## About
Lynk is a minimal framework that works just like AGF. Each script is injected with a `modules` and `shared` table. Server scripts have an additional `server` table, and client scripts have an additional `controllers` table.

## Example
Here's an example of a system I made to test the network. It's comprised of a service in the server and a controller in the client. The server will occationally ping all clients to check their connections. Note that this will require two remote events inside a `Remotes` folder inside of `ReplicatedStorage` called `Ping` and `PingReturn`.
```lua
-- PingService
-- OptimisticSide
-- 12/22/2020

local Players = game:GetService("Players")
local Network

local PingService = {}

function PingService:handlePing(player: Player, ping: number): nil
    -- print a statement about the player's connection based on their ping
    if ping < 350 then
        print(player, "has a good connection")
    elseif ping > 500
        print(player, "has a bad connection")
    else
	    print(player, "has an OK connection")
    end
end

function  PingService:pingClient(player: Player): number
    local completionEvent = Instance.new("BindableEvent") -- fires once the ping is recieved and recorded
    local startTime = 0            -- ping starting time
    local pingTime = math.huge     -- the ping time

    -- create a listener to be ready when the client returns the ping
    local listener = Network:bindToEvent("PingReturn", function(client: Player)
        -- make sure this is the right player
        if  client == player  then
            -- calculate ping and indicate completion
            pingTime =  os.clock() - startTime
            completionEvent:Fire()
        end
    end)

    -- ping the client and wait for completion
    startTime = os.clock()
    Network:fireClient("Ping", player)
    completionEvent.Event:Wait()

    -- unbind the listener and destroy the bindable-event
    listener:unbind()
    completionEvent:Destroy()

    -- return the calculated ping
    return pingTime
end

function PingService:start()
    while self.enabled and wait(self.interval) do
        -- ping all clients
        for _, player in ipairs(Players:GetPlayers()) do
            self:handlePing(player, self:pingClient(player))
        end
    end
end

function  PingService:init()
    -- set up fields
    self.interval =  30       -- how often the server pings all cliends
    self.enabled =  true      -- whether or not the server should run pinging

    -- set up modules
    Network =  self.shared.Network
end

return PingService
```
```lua
-- PingController
-- OptimisticSide
-- 12/22/2020

local Network

local PingController = {}

function  PingController:start()
    -- listen for when the server wants to ping the client
    Network:bindToEvent("Ping", function()
        -- return the ping
        Network:fireServer("PingReturn")
    end)
end

function  PingController:init()
    -- set up modules
    Network =  self.shared.Network
end

return PingController
```