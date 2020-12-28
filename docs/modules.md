# Module
Modules are ways to store code usable on both the server and the client

Modules can also be used like services and controllers, with their `init` and `start` functions, and have all the special fields that can be found in services and controllers, such as `disableInit`.

## Classes
Modules are the preferred location to store classes. You can create a class just as you would for any other class, with the use of meta-tables. Here's an example of how a module can be a class:
```lua
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new()
    local self = {}
    setmetatable(self, MyClass)
    
    return self
end

return MyClass
```

Just because your module is a class does not mean that it cannot access the framework. Just as anything else, you can access framework members through the `init` and `start` function. Here's an example of what how you can access the framework through a module that's for a class: 
```lua
local Signal

local MyClass = {}
MyClass.__index = MyClass

function MyClass.new()
    local self = {}
    setmetatable(self, MyClass)
    
    self.mySignal = Signal.new()

    return self
end

function MyClass:init()
    Signal = self.shared.Signal
end

return MyClass
```

Unfortunately, unlike AeroGameFramework and Knit, you cannot access the framework's members through any of the class's methods. This is why it's best to create variables in a global scope and set their value in the `init` function. 