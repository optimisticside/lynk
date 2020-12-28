# Services
A service is a singleton that is loaded upon start of the server. Services should be used for a specific purpose. For example, you might have a `DataService` to manage players' data or a `NetworkService` to handle server-client communication. They are what controllers are to the server.

# Format
Services, for the most part, are just tables. A service also can have special functions inside it that will interact with the framework and be executed accordingly, as well as special fields that convey information to the framework.

| Field | Description |
| ----- | ----------- |
| `service.disableInit` | Indicates to the framework that it should ignore the `init` member of the service and not treat it as a service initialization function. |
| `service.disableStart` | Indicates to the framework that it should ignore the `start` member of the service and not treat it as a service starter function. |
| `service.disableMetaTable` | Indicates to the framework that it should not make the service a meta-table, and instead manually copy all the fields of the framework over to the service. |
| `service.disableCopy` | Indicates to the framework that it should not copy all the fields of the framework over to the service as an alternative to making the service a meta-table. |
| `service.disableInject` | Indicates to the framework that it should not do anything to the service. |

## Injected methods
All services by default will internally become meta-tables, in which if an index is accessed that does not exists in the service, the index of the framework will be returned. This can be disabled by setting the special-field called `disableMetaTable` to true, which will instead copy all fields of the framework over to the service. If this isn't wanted either, then the special-field called `disableCopy` can be set to true, which will only copy over a member called `framework` over onto the module that can be used to access the framework's members.

## `service:init()`
The `init` method is called once all other services have been required. It is executed synchronously, one by one, for each of the services. It's comparable to a class's constructor. It's recommended that the service's fields be set up before it's finished execution. It's also safe to access other modules and services, but not safe to call any members of them (as they may have not been initialized yet).

## `service:start()`
The `start` method is called once all other services have been required and initialized. It is executed asynchronously on its own thread. From here, it's perfectly safe to call members of other services and modules.