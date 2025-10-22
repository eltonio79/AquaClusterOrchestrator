{ALL}

# WSFieldInfo

Metadata for a field in a network table. This only contains information about the table structure, not the current values for any particular object.

**Methods:**

{{toc}}

## data_type

```ruby
#data_type ⇒ String
```

`EXCHANGE`, `UI`

Returns the data type of the field as a string. This is the InfoWorks type, not the Ruby type - which are shown below:

| WS Type      | Ruby Type       |
| ------------ | --------------- |
| Flag         | String          |
| Boolean      | Boolean         |
| Single       | Float           |
| Double       | Float           |
| Short        | Integer         |
| Long         | Integer         |
| Date         | DateTime        |
| String       | String          |
| Array:Long   | Array\<Integer> |
| Array:Double | Array\<Float>   |
| WSStructure  | WSStructure     |
| GUID         | String          |

Note that Ruby does not have specific types for Single/Double floating point numbers, or Short/Long integers.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## description

```ruby
#description ⇒ String
```

`EXCHANGE`, `UI`

Returns the field description, which is the name of the field that appears in the UI.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## fields

```ruby
#fields ⇒ Array<WSFieldInfo>?
```

`EXCHANGE`, `UI`

Returns an array of fields, if the field is a structure blob i.e. it contains rows of structured data.

If the field is not a structure blob, it will return nil.

**Parameters**

| Name   | Type(s)                  | Description |
| ------ | ------------------------ | ----------- |
| Return | Array\<WSFieldInfo>, nil |             |

## has_time_varying_results?

```ruby
#has_time_varying_results? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns if the field has time varying results, will always be false for network fields. See the `WSTableInfo.results_fields` method.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Boolean |             |

## name

```ruby
#name ⇒ String
```

`EXCHANGE`, `UI`

Returns the database name of the field i.e. the name which is used with Ruby methods.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## read_only?

```ruby
#read_only? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns if the field is read only.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Boolean |             |

## size

```ruby
#size ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the maximum length of a string field. Flag fields will always be length 4, any field which is not a string type will be 0.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |
