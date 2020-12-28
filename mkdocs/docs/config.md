# Config
Lynk allows you to configure how you set up your game to the fullest extent. In `lynk/Layout.lua`, you are able to configure how you want to lay out your game. By default, it should include a part looking something like this:
```lua
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
```

YOu can modify all the fields of the `Layout` table, which is used by the framework scripts for both the server and client. Here is a table that shows what each field of the table means, and where it defaults to.

| Field | Description |
| ----- | ----------- |
| shared | Where shared modules are sored. Defaults to `ReplicatedStorage.Shared` |
| services | Where server services are stored. Defaults to `ServerStorage.Services` |
| modules | Where server/client modules are stored. Defaults to `ServerStorage.Services` when on server, and `PlayerScripts.Modules` when on client |
| contrllers | Where client controllers are stored. Defaults to `PlayerScirpts.Modules` |