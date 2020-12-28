local ExampleController = {}

function ExampleController:start()
    print("Controller starting...")

    while wait(10) do
        print("Controller running...")
    end
end

function ExampleController:init()
    print("Controller initializing...")
end

return ExampleController