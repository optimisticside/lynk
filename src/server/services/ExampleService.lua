local ExampleService = {}

function ExampleService:start()
    print("Service starting...")

    while wait(10) do
        print("Service running...")
    end
end

function ExampleService:init()
    print("Service initializing...")
end

return ExampleService