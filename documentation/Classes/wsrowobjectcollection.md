{ALL}

# WSRowObjectCollection

A collection of [WSRowObject](wsrowobject.md)s.

**Methods:**

{{toc}}

## [] (Get Index)

```ruby
#[(index)] ⇒ WSRowObject?
```

`EXCHANGE`, `UI`

Returns the [WSRowObject](wsrowobject.md) from the collection at the specified index.

**Parameters**

| Name   | Type(s)                            | Description                                                   |
| ------ | ---------------------------------- | ------------------------------------------------------------- |
| index  | Integer                            | The index requested (zero-based).                             |
| Return | [WSRowObject](wsrowobject.md), nil | The object found, or nil if there is no object at this index. |

## each

```ruby
#each { |ro| ... } ⇒ WSRowObject
```

`EXCHANGE`, `UI`

Iterates through the collection, yielding a [WSRowObject](wsrowobject.md).

**Examples**

```ruby
network.row_object_collection('_nodes').each { |ro| puts ro.id }
```

```ruby
network.row_object_collection('_nodes').each do |ro|
  puts ro.id
end
```

## length

```ruby
#length ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the length of this collection, i.e. how many [WSRowObject](wsrowobject.md)s it contains.
