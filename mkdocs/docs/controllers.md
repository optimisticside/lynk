# Controller
A controller is a singleton that is loaded upon start of the client. Controllers should be used for a specific purpose. For example, you might have a `InterfaceController` to manage the player's interface or a `InputController` to handle input. They are what services are to the server.

# Format
Controllers, for the most part, are just tables. A controller also can have special functions inside it that will interact with the framework and be executed accordingly, as well as special fields that convey information to the framework.

| Field | Description |
| ----- | ----------- |
| `controller.disableInit` | Indicates to the framework that it should ignore the `init` member of the controller and not treat it as a controller initialization function. |
| `controller.disableStart` | Indicates to the framework that it should ignore the `start` member of the controller and not treat it as a controller starter function. |
| `controller.disableMetaTable` | Indicates to the framework that it should not make the controller a meta-table, and instead manually copy all the fields of the framework over to the controller. |
| `controller.disableCopy` | Indicates to the framework that it should not copy all the fields of the framework over to the controller as an alternative to making the controller a meta-table. |
| `controller.disableInject` | Indicates to the framework that it should not do anything to the controller. |

## Injected methods
All controller by default will internally become meta-tables, in which if an index is accessed that does not exists in the controller, the index of the framework will be returned. This can be disabled by setting the special-field called `disableMetaTable` to true, which will instead copy all fields of the framework over to the controller. If this isn't wanted either, then the special-field called `disableCopy` can be set to true, which will only copy over a member called `framework` over onto the module that can be used to access the framework's members.

## `controller:init()`
The `init` method is called once all other controllers have been required. It is executed synchronously, one by one, for each of the controllers. It's comparable to a class's constructor. It's recommended that the controller's fields be set up before it's finished execution. It's also safe to access other modules and controllers, but not safe to call any members of them (as they may have not been initialized yet).

## `controller:start()`
The `start` method is called once all other controllers have been required and initialized. It is executed asynchronously on its own thread. From here, it's perfectly safe to call members of other controllers and modules. 