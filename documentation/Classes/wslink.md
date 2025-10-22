{ALL}

# WSLink

[WSRowObject](./wsrowobject.md) > WSLink

A link object i.e. a `WSRowObject` with a `category` type `link`.

**Methods:**

{{toc}}

## ds_node

```ruby
#ds_node ⇒ WSNode?
```

`EXCHANGE`, `UI`

Returns the link's downstream node, or nil if it doesn't have one.

## us_node

```ruby
#us_node ⇒ WSNode?
```

`EXCHANGE`, `UI`

Returns the link's upstream node, or nil if it doesn't have one.
