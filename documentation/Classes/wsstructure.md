{ALL}

# WSStructure

A structure blob field of a [WSRowObject](wsrowobject.md), i.e. a field that contains an array of structured data.

It is a collection of [WSStructureRow](wsstructurerow.md) objects, each of which represents a single row / entry in the structure. The collection has a fixed length which can be updated with the [length=](#length-1) method. You cannot dynamically insert or remove objects, you must first set the length and access objects by their index.

If any changes are made to the length or the [WSStructureRow](wsstructurerow.md) objects, the [write](#write) method must be used on both this object **and** the parent [WSRowObject](wsrowobject.md).

**Methods:**

{{toc}}

## [] (Get Index)

```ruby
#[(index)] ⇒ WSStructureRow?
```

`EXCHANGE`, `UI`

Returns the object from the collection at the specified index.

**Parameters**

| Name   | Type(s)                                  | Description                                                   |
| ------ | ---------------------------------------- | ------------------------------------------------------------- |
| index  | Integer                                  | The index requested (zero-based).                             |
| Return | [WSStructureRow](wsstructurerow.md), nil | The object found, or nil if there is no object at this index. |

## each

```ruby
#each { |row| ... } ⇒ WSStructureRow
```

`EXCHANGE`, `UI`

Iterates through the collection, yielding a [WSStructureRow](wsstructurerow.md) object. This is similar to iterating through the rows of a table.

**Examples**

```ruby
struct.each { |row| puts row['date_time'] }
```

```ruby
struct.each.each do |row|
  puts row['date_time']
end
```

## length

```ruby
#length ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the length of the structure, i.e. how many rows it contains. Each row is a [WSStructureRow](wsstructurerow.md) object.

## length= (Set)

```ruby
#length=(length) ⇒ void
```

`EXCHANGE`, `UI`

Sets the length of the structure, i.e. how many rows it contains. Each row is a [WSStructureRow](wsstructurerow.md) object.

**Examples**

To add to the structure, you must first use this method to set the appropriate length. You can also reference the current length, e.g. to add one new row:

```ruby
structure.length = structure.length + 1
```

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| length | Integer |             |

## write

```ruby
#write ⇒ void
```

`EXCHANGE`, `UI`

Writes any changes to this object and the [WSStructureRow](wsstructurerow.md) objects it contains.

The `#write` method on the parent [WSRowObject](wsrowobject.md) must also be used.
