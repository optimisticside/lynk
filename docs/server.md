# Server framework
Lynk's server and client frameworks are for the most part, quite similar. They both offer identical functions that serve the same purposes on both ends. Note that any members here can be accessed through any other modules' and services' methods through the meta-table injected into the `self` parameter. This is how they are able to access fields such as `modules` and `shared`.

## Fields
These are some notable and useful fields that are inside Lynk's server framework.

### `framework.modules`
This is where the framework's modules are stored. Note that this table is not initialized upon start-up, and shouldn't be accessed until initialization time. A module can be accessed by refrencing it's name. For example, if someone wanted to acccess a module called `Interface`, they would do `modules.Interface`.

### `framework.shared`
This is where the framework's shared modules are stored. Note that this table is not initialized upon start-up, and shouldn't be accessed until initialization time. A shared module can be accessed by refrencing it's name. For example, if someone wanted to acccess a module called `Network`, they would do `shared.Network`.

### `framework.services`
This is where the framework's services are stored. Note that this table is not initialized upon start-up, and shouldn't be accessed until initialization time. A service can be accessed by refrencing it's name. For example, if someone wanted to acccess a service called `DataService`, they would do `modules.DataService`.

## Methods
These are some notable and useful methods that are inside Lynk's server framework.

### `framework:createModule(name, initialData)`
This will create a module inside the framework, and is how you can create a module outside of the framework's structure. It takes one parameter (`name`, which is a string and represents the name of the module), and another optional parameter (`initialData`, which is a table and represents any initial data to be added to the module). This function returns a table, which can be used just as any other, and other memebers can be added accordingly.

### `framework:createShared(name, initialData)`
This will create a shared module inside the framework, and is how you can create one outside of the framework's structure. Please note that this data will not replicate to the clients, and will only be available in the server. It takes one parameter (`name`, which is a string and represents the name of the shared module), and another optional parameter (`initialData`, which is a table and represents any initial data to be added to the shared module). This function returns a table, which can be used just as any other, and other memebers can be added accordingly.

### `framework:createService(name, initialData)`
This will create a service inside the framework, and is how you can create a service outside of the framework's structure. It takes one parameter (`name`, which is a string and represents the name of the service), and another optional parameter (`initialData`, which is a table and represents any initial data to be added to the service). This functionr returns a table, which can be used just as any other, and other memebers can be added accordingly.

## Other
Here are a list of some other fields and methods of the server framework. These are here probably because they're used internally for some reason.

### Fields
| Name | Description |
| ---- | ----------- |
|  `framework.startTime` | The time when the framework started. |

### Methods
| Name | Description |
| ---- | ----------- |
| `framework:requireModule(name, module)` | Requires a module in a protected thread. |
| `framework:initModule(module)` | Initializes a module if everything checks out. |
| `framework:startModule(module)` | Starts a module if everything checks out. |
| `framework:wrap(name, module)` | Wraps a module's raw-table and injects members accordingly. |
| `framework:setup()` | Sets up any modules, and adds them to the appropriate table. |
| `framework:start()` | Initializes all modules, and then starts all of them. |
| `framework:init()` | Starts the framework. |