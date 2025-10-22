{ALL}

# WSValidation

A single validation message.

All methods in this class are read only, and return the value of one of the fields found in the UI validation window.

**Methods:**

{{toc}}

## code

```ruby
#code ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the code of the validation message.

## field

```ruby
#field ⇒ String
```

`EXCHANGE`, `UI`

Returns the field name. This may not be a real database field, but if it is then the actual field name rather than the description (the name used in the UI) will be returned.

```ruby
puts validation.field
⇒ 'wn_node'
```

## field_description

```ruby
#field_description ⇒ String
```

`EXCHANGE`, `UI`

Returns the field description. The field description is how the field would appear in the UI.

```ruby
puts validation.field_description
⇒ 'node'
```

## message

```ruby
#message ⇒ String
```

`EXCHANGE`, `UI`

Returns the text content of validation message.

## object_id

```ruby
#object_id ⇒ String?
```

`EXCHANGE`, `UI`

Returns the object ID from the validation message, if any.

## object_type

```ruby
#object_type ⇒ String?
```

`EXCHANGE`, `UI`

Returns the object type from the validation message, if any.

## priority

```ruby
#priority ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the priority of the validation message.

## scenario

```ruby
#scenario ⇒ String
```

`EXCHANGE`, `UI`

Returns the scenario name for the validation message.

**Parameters**

| Name   | Type(s) | Description                                            |
| ------ | ------- | ------------------------------------------------------ |
| Return | String  | Name of the scenario, or 'base' for the base scenario. |

## type

```ruby
#type ⇒ String
```

`EXCHANGE`, `UI`

Returns the type of the validation message as a string.

**Parameters**

| Name   | Type(s) | Description                                  |
| ------ | ------- | -------------------------------------------- |
| Return | String  | One of `error`, `warning`, or `information`. |
