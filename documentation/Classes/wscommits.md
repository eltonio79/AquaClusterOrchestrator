{ALL}

# WSCommits

A collection of [WSCommit](wscommit.md) objects, representing the commit history of a [WSModelObject](wsmodelobject.md) using merge version control.

**Methods:**

{{toc}}

## [] (Get Index)

```ruby
#[(index)] ⇒ WSCommit?
```

`EXCHANGE`, `UI`

Returns the [WSCommit](wscommit.md) from the collection at the specified index.

**Parameters**

| Name   | Type(s)                      | Description                                                                    |
| ------ | ---------------------------- | ------------------------------------------------------------------------------ |
| index  | Integer                      | The index requested (zero-based).                                              |
| Return | [WSCommit](wscommit.md), nil | The [wscommit](wscommit.md) found, or nil if there is no object at this index. |

## each

```ruby
#each { |c| ... } ⇒ WSCommit
```

`EXCHANGE`, `UI`

Iterates through the collection, yielding a [WSCommit](wscommit.md).

```ruby
commits.each { |c| puts c.branch_id }
```

```ruby
commits.each.each do |c|
  puts "#{c.branch_id} - User '#{c.user}' changed #{c.modified_count} objects!"
end
```

## length

```ruby
#length ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the length of this collection i.e. how many [WSCommit](wscommit.md)s it contains.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |
