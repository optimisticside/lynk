local ExampleModule = {}

ExampleModule.disableStart = true
ExampleModule.disableInit = true

function ExampleModule:start()
    print("Module starting...")

    while wait(10) do
        print("Module running...")
    end
end

function ExampleModule:init()
    print("Module initializing...")
end

return ExampleModule