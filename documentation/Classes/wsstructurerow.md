{ALL}

# WSStructureRow

A single element (row) in a [WSStructure](wsstructure.md).

**Methods:**

{{toc}}

## [] (Get Field)

```ruby
#[(field)] ⇒ Any
```

`EXCHANGE`, `UI`

Returns the value of the named field, which could be any data type.

```ruby
puts struct_row['flow']
⇒ 42.01
```

**Parameters**

| Name   | Type(s) | Description             |
| ------ | ------- | ----------------------- |
| field  | String  | The field name.         |
| Return | Any     | The value of the field. |

## []= (Set Field)

```ruby
#[(field)]=(value) ⇒ void
```

`EXCHANGE`, `UI`

Sets the value of the named field. The value's Ruby type should be appropriate for the field, e.g. a date field requires a Ruby `DateTime` object.

For any changes to be saved, the parent [WSStructure.write](wsstructure.md) method must be used.

```ruby
struct_row['date_time'] = DateTime.now
struct_row['flow'] = 42.01
```

**Parameters**

| Name  | Type(s) | Description                                                                   |
| ----- | ------- | ----------------------------------------------------------------------------- |
| field | String  | The field name.                                                               |
| value | Any     | The value for the field, must be appropriate type to be stored in this field. |
