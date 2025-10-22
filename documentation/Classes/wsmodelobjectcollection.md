{ALL}

# WSModelObjectCollection

A collection of `WSModelObject` objects (including derived classes).

**Methods:**

{{toc}}

## [] (Get Index)

```ruby
#[(index)] ⇒ WSModelObject?
```

`EXCHANGE`, `UI`

Returns the object from the collection at the specified index.

**Parameters**

| Name   | Type(s)            | Description                                                   |
| ------ | ------------------ | ------------------------------------------------------------- |
| index  | Integer            | The index requested (zero-based).                             |
| Return | WSModelObject, nil | The object found, or nil if there is no object at this index. |

## each

```ruby
#each { |mo| ... } ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Iterates through the collection, yielding a `WSModelObject`.

For example, using `WSDatabase.model_object_collection`:

```ruby
database.model_object_collection('Geometry').each { |mo| puts mo.name }
```

```ruby
database.model_object_collection('Geometry').each do |mo|
  puts mo.name
end
```

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | WSModelObject |             |

## length

```ruby
#length ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of objects in this collection.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |
