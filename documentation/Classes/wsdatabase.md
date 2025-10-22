{ALL}

# WSDatabase

A database, including cloud databases and transportable databases.

The majority of these methods are only available in Exchange, there is only limited functionality in the UI. A database can be accessed from `WSApplication.open` (with Exchange) or `WSApplication.current_database` (with UI).

**Methods:**

{{toc}}

## copy_into_root

```ruby
#copy_into_root(object, copy_results, copy_ground_models) ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Copies a [WSModelObject](wsmodelobject.md) and any children into the database root, returning the new model object. The model object being copied could be from the same database, or another database such as a transportable database.

**Parameters**

| Name               | Type(s)                           | Description                                                                                               |
| ------------------ | --------------------------------- | --------------------------------------------------------------------------------------------------------- |
| object             | [WSModelObject](wsmodelobject.md) | The model object to copy.                                                                                 |
| copy_results       | Boolean                           | Whether to copy simulation results, if the model object (or it's children) have simulations with results. |
| copy_ground_models | Boolean                           | Whether to copy ground models.                                                                            |
| Return             | [WSModelObject](wsmodelobject.md) | The newly copied object in this database.                                                                 |

## file_root

```ruby
#file_root ⇒ String
```

`EXCHANGE`, `UI`

Returns the path used by this database for files such as GIS layers, also known as the Remote Files Root.

This is the path shown in the UI under File > Database Settings > Set Remote Roots > Remote Files Root.

If this is a standalone database, and "force all remote roots to be below the database" is enabled, then the path will be the folder containing the database.

## find_root_model_object

```ruby
#find_root_model_object(type, name) ⇒ WSModelObject?
```

`EXCHANGE`, `UI`

Returns the [WSModelObject](wsmodelobject.md) at the root (top level) of the database. Model objects at this level will have unique names.

{::ICM}
The valid types at this level are `Asset Group`, `Model Group`, and `Master Group`.
{::/ICM}

{::WSPRO}
The only valid type at this level is a `Catchment Group`.
{::/WSPRO}

**Parameters**

| Name   | Type(s)                                | Description                              |
| ------ | -------------------------------------- | ---------------------------------------- |
| type   | String                                 | The scripting type of the object.        |
| name   | String                                 | The name of the object (case sensitive). |
| Return | [WSModelObject](wsmodelobject.md), nil | The object if found, nil otherwise.      |

## guid

```ruby
#guid ⇒ String
```

`EXCHANGE`, `UI`

Returns the GUID for the database, which is also called the database identifier in the user interface.

```ruby
puts database.guid
=> 'CEB7E8B9-D383-485C-B085-19F6E3E3C8CD'
```

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## list_read_write_run_fields

```ruby
#list_read_write_run_fields ⇒ Array<String>
```

`EXCHANGE`, `UI`

Returns the field names in run objects that are read-write i.e. fields that can be set from Exchange scripts.

```ruby
database.list_read_write_run_fields.each { |field| puts field }
```

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | Array\<String> |             |

## merge_migration_file

```ruby
#merge_migration_file(file_name, log_file, import_type, mapping_file) ⇒ void
```

`EXCHANGE`, `UI`

This method merges a migration file into the database.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| file_name	 | String | Path to the input file.             |
| log_file	 | String | Path to the log file.            |
| import_type		 | Integer | Import type (0 = normal, 1 = tree only, 2 = contents only) |
| mapping_file	 | String | Path to the mapping file.     |
## model_object

```ruby
#model_object(path) ⇒ WSModelObject?
```

`EXCHANGE`, `UI`

Finds a [WSModelObject](wsmodelobject.md) in the database using its scripting path.

```ruby
network = database.model_object('>MODG~My Root Model Group')
raise "Could not find network" if network.nil?
```

**Parameters**

| Name | Type(s) | Description                       |
| ---- | ------- | --------------------------------- |
| path | String  | The scripting path to the object. |

## model_object_collection

```ruby
#model_object_collection(type) ⇒ WSModelObjectCollection
```

`EXCHANGE`, `UI`

Finds all [WSModelObject](wsmodelobject.md)s in the database of a given type.

{::ICM}

```ruby
database.model_object_collection('Rainfall Event').each do |model_object|
  puts model_object.name
end
```

{::/ICM}

{::WSPRO}

```ruby
database.model_object_collection('Geometry').each do |model_object|
  puts model_object.name
end
```

{::/WSPRO}

**Parameters**

| Name   | Type(s)                                               | Description                                                                            |
| ------ | ----------------------------------------------------- | -------------------------------------------------------------------------------------- |
| type   | String                                                | The scripting type of the object.                                                      |
| Return | [WSModelObjectCollection](wsmodelobjectcollection.md) | The object(s) found, will be an empty collection if there are no objects of this type. |

## model_object_from_type_and_guid

```ruby
#model_object_from_type_and_guid(type, guid) ⇒ WSModelObject?
```

`EXCHANGE`, `UI`

Finds a [WSModelObject](wsmodelobject.md) in the database using its scripting type and GUID. The GUID can be found in the user interface via the properties dialog.

{::ICM}

```ruby
rainfall = database.model_object_from_type_and_guid('Rainfall Event', '{CEB7E8B9-D383-485C-B085-19F6E3E3C8CD}')
raise "Could not find rainfall" if rainfall.nil?
```

{::/ICM}

{::WSPRO}

```ruby
network = database.model_object_from_type_and_guid('Geometry', '{CEB7E8B9-D383-485C-B085-19F6E3E3C8CD}')
raise "Could not find network" if network.nil?
```

{::/WSPRO}

**Parameters**

| Name   | Type(s)                                | Description                         |
| ------ | -------------------------------------- | ----------------------------------- |
| type   | String                                 | The scripting type of the object.   |
| guid   | String                                 | The creation guid.                  |
| Return | [WSModelObject](wsmodelobject.md), nil | The object if found, nil otherwise. |

## model_object_from_type_and_id

```ruby
#model_object_from_type_and_id(type, id) ⇒ WSModelObject?
```

`EXCHANGE`, `UI`

Finds a [WSModelObject](wsmodelobject.md) in the database using its scripting type and ID. The ID can be found in the user interface via the properties dialog.

{::ICM}

```ruby
rainfall = database.model_object_from_type_and_id('Rainfall Event', 1)
raise "Could not find rainfall" if rainfall.nil?
```

{::/ICM}

{::WSPRO}

```ruby
network = iwdb.model_object_from_type_and_id('Geometry', 1)
raise "Could not find network" if network.nil?
```

{::/WSPRO}

**Parameters**

| Name   | Type(s)                                | Description                         |
| ------ | -------------------------------------- | ----------------------------------- |
| type   | String                                 | The scripting type of the object.   |
| id     | Integer                                | The model id.                       |
| Return | [WSModelObject](wsmodelobject.md), nil | The object if found, nil otherwise. |

## new_model_object

```ruby
#new_model_object(type, name) ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Creates a [WSModelObject](wsmodelobject.md) in the root of the database.

{::ICM}
The valid object types at this level are `Asset Group`, `Model Group`, or `Master Group`.
{::/ICM}

{::WSPRO}
The only valid object type at this level is `Catchment Group`.
{::/WSPRO}

**Parameters**

| Name | Type(s) | Description                                                                             |
| ---- | ------- | --------------------------------------------------------------------------------------- |
| type | String  | The scripting type of the object - must be a valid type for this level of the database. |
| name | String  | The name of the new object, must be unique.                                             |

**Exceptions**

- **unrecognised type** - if the object type is not valid
- **invalid object type for the root of a database** - if the object type is valid, but not allowed for this level of the database (see method description)
- **an object of this type and name already exists in root of database** - object names must be unique
- **licence and/or permissions do not permit creation of a child of this type in the root of the database** - if the object cannot be created in the root of the database for licence and/or permission reasons (not applicable to some products / licenses)
- **unable to create object** - if the creation fails for some other reason

## new_network_name

```ruby
#new_network_name(type, name, branch, add) ⇒ String
```

`EXCHANGE`, `UI`

Generates a new network (model object) name. This is intended to be used with an existing model object's name to generate a unique variant for a new network model object.

```ruby
new_name = database.new_network_name('Model Network', 'Badger', false, false)
⇒ Badger#1
```

**Parameters**

| Name   | Type(s) | Description                                                                                                                    |
| ------ | ------- | ------------------------------------------------------------------------------------------------------------------------------ |
| type   | String  | The scripting type of the object.                                                                                              |
| name   | String  | The base name.                                                                                                                 |
| branch | Boolean | If true, the number increment will be an underscore e.g. `mynetwork_1`. if false, it will be a hash symbol e.g. `mynetwork#1`. |
| add    | Boolean | If true, #1 or \_1 will always be appended to the name, instead of incrementing the number.                                    |
| Return | String  | The new name.                                                                                                                  |

## path

```ruby
#path ⇒ String
```

`EXCHANGE`, `UI`

Returns the path of the database.

This is the same path that would be used by [WSApplication.open](wsapplication.md), for example:

{::ICM}

- Transportable database: 'C:/Badger/MyDatabase.icmt'
- Standalone database: 'C:/Badger/MyDatabase.icmm'
- Workgroup database: 'localhost:40000/Badger/MyDatabase'

{::/ICM}

{::WSPRO}

- Transportable database: 'C:/Badger/MyDatabase.wspt'
- Standalone database: 'C:/Badger/MyDatabase.wspm'
- Workgroup database: 'localhost:40000/Badger/MyDatabase'

{::/WSPRO}

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## result_root

```ruby
#result_root ⇒ String
```

`EXCHANGE`, `UI`

Returns the path used by this database for results files when results are stored 'on server', also known as the Remote Results Root.

This is the path shown in the UI under File > Database Settings > Set Remote Roots > Remote Results Root.

If this is a standalone database, and "force all remote roots to be below the database" is enabled, then the path will be the folder containing the database.

## root_model_objects

```ruby
#root_model_objects ⇒ WSModelObjectCollection
```

`EXCHANGE`, `UI`

Finds all the objects at the root (top level) of the database.

{::WSPRO}

## use_merge_version_control=

```ruby
#use_merge_version_control=(bool) ⇒ void
```

`EXCHANGE`, `UI`

Sets if the database should use merge version control for new objects. If false, then the database will use the legacy lock version control instead.

The relevant network types are [WSNumbatNetworkObject](wsnumbatnetworkobject.md) for merge control, or [WSNetworkObject](wsnetworkobject.md) for legacy lock version control.

Note that IWLive Pro Baseline objects are always lock version control, regardless of this setting.

{::/WSPRO}

{::WSPRO}

## use_merge_version_control?

```ruby
#use_merge_version_control? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns if the database using merge version control for new objects. If false, then the database is using the legacy lock version control.

The relevant network types are [WSNumbatNetworkObject](wsnumbatnetworkobject.md) for merge control, or [WSNetworkObject](wsnetworkobject.md) for legacy lock version control.

Note that IWLive Pro Baseline objects are always lock version control, regardless of this setting.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Boolean |             |

{::/WSPRO}

{::WSPRO}

## version

```ruby
#version ⇒ String
```

`EXCHANGE`, `UI`

Returns the version of the database.

{::/WSPRO}
