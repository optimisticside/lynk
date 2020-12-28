# Ping Handler
I had originally made this to test out the `Network` module, so I decided to just add it as an example. It's comprised of two scripts, one being a service on the server, and the other being a controller on the client. Every now and then, the server will ping all the clients, and determine their connection quality and print it to output.

Note that for this to work, you need two remote-events called `Ping` and `PingReturn` inside a folder called `Remotes` in `ReplicatedStorage` (configurable in `Network` module), as well as the `Network` module (provided by default but optional).

Here's the `PingService` service module-script on the server.
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

Here's the `PingController` controller module-script on the client.
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