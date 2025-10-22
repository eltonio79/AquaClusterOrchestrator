{ALL}

# WSRowObject

An individual object in a network.

Methods that return this type of object may actually return a derived class, for example a [WSNode](wsnode.md) for nodes or [WSLink](wslink.md) for links.

**Methods:**

{{toc}}

## . (Get Field)

```ruby
#.(field) ⇒ Any
```

`EXCHANGE`, `UI`

Returns the value of a field, using dot syntax. May return a simple value, or a [WSStructure](wsstructure.md) if the field is a structure blob.

Note: When accessing the contents of the 'Category' data field within the General Line table (hw_general_line) or General Point table (hw_general_point), you must use the [] operator with the category field name, otherwise the application may return unexpected results. 

This is because the name "category" is both a method (see [#category](#category)) on a WSRowObject and a field name within these tables. The method is found and its value returned before the field names are searched. 

```ruby
puts node.'node_id'
⇒ 'Badger'
```

**Parameters**

| Name  | Type(s) | Description            |
| ----- | ------- | ---------------------- |
| field | String  | The name of the field. |

## [] (Get Field)

```ruby
#[(field)] ⇒ Any
```

`EXCHANGE`, `UI`

Returns the value of a field, using hash-like syntax. May return a simple value, or a [WSStructure](wsstructure.md) if the field is a structure blob.

```ruby
puts node['node_id']
⇒ 'Badger'
```

**Parameters**

| Name  | Type(s) | Description            |
| ----- | ------- | ---------------------- |
| field | String  | The name of the field. |

## []= (Set Field)

```ruby
#[(field)]=(value) ⇒ void
```

`EXCHANGE`, `UI`

Sets the value of a field, using hash-like syntax. The value must be an appropriate type for the field, and this cannot be used to set structure blobs.

```ruby
node['node_id'] = 'Badger'
```

**Parameters**

| Name  | Type(s) | Description                                           |
| ----- | ------- | ----------------------------------------------------- |
| field | String  | The name of the field.                                |
| value | Any     | The value, must be an appropriate type for the field. |

## \_\* (Get Tag)

```ruby
#_* ⇒ Any
```

`EXCHANGE`, `UI`

Reads the value of a tag, which are temporary values added to the object during the script.

```ruby
puts mo._badger
⇒ 'Penguin'
```

## \_\*= (Set Tag)

```ruby
#_*=(value) ⇒ void
```

`EXCHANGE`, `UI`

Sets the value of a tag, which are user defined temporary values added to the object during the script. The name of tags can contain only alphanumeric characters (i.e. letters and numbers).

```ruby
mo._badger = 'Penguin'
```

## autoname

```ruby
#autoname ⇒ void
```

`EXCHANGE`, `UI`

Sets the ID of this object using the current network autoname convention.

## category

```ruby
#category ⇒ String
```

`EXCHANGE`, `UI`

Returns the category name of the object e.g. `_nodes`, `_links`.

## contains?

```ruby
#contains(other) ⇒ Boolean
```

`EXCHANGE`, `UI`

If this object is a polygon, checks if another WSRowObject is inside it. This is effectively the inverse of the `#is_inside?` method.

**Parameters**

| Name   | Type(s)     | Description                                 |
| ------ | ----------- | ------------------------------------------- |
| other  | WSRowObject | The other object.                           |
| Return | Boolean     | If the other object is inside this polygon. |

## delete

```ruby
#delete ⇒ void
```

`EXCHANGE`, `UI`

Deletes the row object. This is immediate and does not require the `#write` method.

## field

```ruby
#field(name) ⇒ WSFieldInfo?
```

`EXCHANGE`, `UI`

Returns the [WSFieldInfo](wsfieldinfo.md) object for a given field name.

This only returns information about the named field such as it's data type, not any data associated with this particular object.

{::ICM}

## gauge_results

```ruby
#gauge_results(field) ⇒ Array<Float>
```

`EXCHANGE`, `UI`

Returns an array of values for the given results field name, at all gauge time-steps. The field must have time varying results.

If the object or field does not have gauge results it will return the regular results.

If the simulation results time-step multiplier is 0, this method will return no results, even if gauge results are available in the user interface.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| field  | String        |             |
| Return | Array\<Float> |             |

{::/ICM}

## id

```ruby
#id => String
```

`EXCHANGE`, `UI`

Returns the ID of the object.

If the object has a multi-part primary key (such as a link) then the key will be output with parts separated by a `.` character, similar to accessing the OID field in SQL.

```ruby
puts node.id
=> "ST39469"
```

```ruby
puts link.id
=> "ST41337.ST34322.1"
```

## id= (Set)

```ruby
#id=(new_id) ⇒ void
```

`EXCHANGE`, `UI`

Sets the ID of the object. Will raise an exception if the ID cannot be set e.g. is a duplicate.

**Parameters**

| Name   | Type(s) | Description                                                                                                |
| ------ | ------- | ---------------------------------------------------------------------------------------------------------- |
| new_id | String  | The new id, which must be unique and formatted the same way as an id retrieved from the [#id](#id) method. |

## is_inside?

```ruby
#is_inside?(other) ⇒ Boolean
```

`EXCHANGE`, `UI`

Checks if this object is inside a polygon.

**Parameters**

| Name   | Type(s)     | Description                                     |
| ------ | ----------- | ----------------------------------------------- |
| other  | WSRowObject | The other object, which should be a polygon.    |
| Return | Boolean     | If this object is inside the other wsrowobject. |

## navigate

```ruby
#navigate(type) ⇒ Array<WSRowObject>
```

`EXCHANGE`, `UI`

Navigates between objects and other objects based on their relationship. Supports one-to-one and one-to-many relationships, and returns an array of objects.

See also: [#navigate1](#navigate1)

| Name                | Has Results | One to Many |
| ------------------- | :---------: | :---------: |
| alt_demand          |     No      |     No      |
| cctv_surveys        |     No      |     Yes     |
| custom              |     No      |     No      |
| data_logger         |     No      |     No      |
| drain_tests         |     No      |     Yes     |
| ds_flow_links       |     Yes     |     Yes     |
| ds_links            |     Yes     |     Yes     |
| ds_node             |     Yes     |     No      |
| dye_tests           |     No      |     Yes     |
| gps_surveys         |     No      |     Yes     |
| hydrant_tests       |     No      |     Yes     |
| incidents           |     No      |     Yes     |
| joined              |     No      |     No      |
| joined_pipes        |     No      |     Yes     |
| lateral_pipe        |     No      |     No      |
| maintenance_records |     No      |     Yes     |
| manhole_repairs     |     No      |     Yes     |
| manhole_surveys     |     No      |     Yes     |
| meter_tests         |     No      |     Yes     |
| meters              |     No      |     Yes     |
| monitoring_surveys  |     No      |     Yes     |
| node                |     Yes     |     No      |
| pipe                |     Yes     |     No      |
| pipe_cleans         |     No      |     Yes     |
| pipe_repairs        |     No      |     Yes     |
| pipe_samples        |     No      |     Yes     |
| properties          |     No      |     Yes     |
| property            |     No      |     No      |
| sanitary_manhole    |     No      |     No      |
| sanitary_pipe       |     No      |     No      |
| smoke_defects       |     No      |     Yes     |
| smoke_test          |     No      |     No      |
| smoke_tests         |     No      |     Yes     |
| storm_manhole       |     No      |     No      |
| storm_pipe          |     No      |     No      |
| us_flow_links       |     Yes     |     Yes     |
| us_links            |     Yes     |     Yes     |
| us_node             |     Yes     |     No      |

**Parameters**

| Name | Type(s) | Description                                  |
| ---- | ------- | -------------------------------------------- |
| type | String  | The navigation type, see method description. |

## navigate1

```ruby
#navigate1(type) ⇒ WSRowObject?
```

`EXCHANGE`, `UI`

Navigates between objects and other objects based on their relationship. Supports one-to-one relationships, and returns a single object if found.

See also: [#navigate](#navigate)

**Parameters**

| Name | Type(s) | Description                                  |
| ---- | ------- | -------------------------------------------- |
| type | String  | The navigation type, see method description. |

## objects_in_polygon

```ruby
#objects_in_polygon(type) ⇒ Array<WSRowObject>
```

`EXCHANGE`, `UI`

If this object is a polygon, returns an array of the `WSRowObject` objects inside it, matching the `type` parameter.

When using an array of strings as the `type`, all values must be unique (no duplicates) and cannot contain a category and a table within the same category. This is similar to the `WSNumbatNetworkObject.search_at_point` method.

**Parameters**

| Name | Type(s)                     | Description                                                              |
| ---- | --------------------------- | ------------------------------------------------------------------------ |
| type | String, Array\<String>, nil | The name(s) of a type or category of object, nil will search all tables. |

## result

```ruby
#result(field) ⇒ Float
```

`EXCHANGE`, `UI`

Returns the value for the given results field, at the current time-step.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| field  | String  |             |
| Return | Float   |             |

## results

```ruby
#results(field) ⇒ Array<Float>
```

`EXCHANGE`, `UI`

Returns an array of values for the given results field name, at all timesteps. The field must have time varying results.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| field  | String        |             |
| Return | Array\<Float> |             |

## selected= (Set)

```ruby
#selected=(bool) ⇒ void
```

`EXCHANGE`, `UI`

Sets whether this object is selected or deselected. This does not need to occur within a transaction.

**Parameters**

| Name | Type(s) | Description                                                                                                                 |
| ---- | ------- | --------------------------------------------------------------------------------------------------------------------------- |
| bool | Boolean | If the object is selected, this could be an explicit `true` or `false`, or a statement that evaluates to `true` or `false`. |

## selected?

```ruby
#selected? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns if the object is currently selected.

## table

```ruby
#table ⇒ String
```

`EXCHANGE`, `UI`

Returns the object's table name.

## table_info

```ruby
#table_info ⇒ WSTableInfo
```

`EXCHANGE`, `UI`

Returns a [WSTableInfo](wstableinfo.md) for this object's table, which contains metadata about the table structure.

## write

```ruby
#write ⇒ void
```

`EXCHANGE`, `UI`

Writes any changes to the object, such as modified field values.
