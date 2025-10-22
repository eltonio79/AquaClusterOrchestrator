{ALL}

# WSNode

[WSRowObject](./wsrowobject.md) > WSNode

A node object.

**Methods:**

{{toc}}

{::WSPRO}

## add_user_demand

```ruby
#add_user_demand(options) ⇒ void

```

`EXCHANGE`, `UI`

Adds demand to a node.

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| options   | Hash	 | Field values for the demand.  |

**Example**

```ruby
net = WSApplication.current_network
node = net.row_object('wn_node','ST28360706')
hash = Hash.new
hash['category_id'] = '10H'
hash['category_type'] = 0
hash['no_of_properties'] = 1
hash['spec_consumption'] = 450
hash['scenario_id'] = ''
net.transaction_begin
node.add_user_demand(hash)
net.transaction_commit
```

{::/WSPRO}

## ds_links

```ruby
#ds_links ⇒ WSRowObjectCollection<WSLink>
```

`EXCHANGE`, `UI`

Returns a collection of the node's downstream links, if there are no downstream links the collection will be empty.

**Parameters**

| Name   | Type(s)                       | Description |
| ------ | ----------------------------- | ----------- |
| Return | WSRowObjectCollection\<WSLink> |             |

## us_links

```ruby
#us_links ⇒ WSRowObjectCollection<WSLink>
```

`EXCHANGE`, `UI`

Returns a collection of the node's upstream links, if there are no upstream links the collection will be empty.

**Parameters**

| Name   | Type(s)                       | Description |
| ------ | ----------------------------- | ----------- |
| Return | WSRowObjectCollection\<WSLink> |             |


{::WSPRO}

## user_demand_options

```ruby
#user_demand_options() ⇒ Hash

```

`EXCHANGE`, `UI`

Returns node demand as a hash of field values.

**Example**

```ruby
net = WSApplication.current_network
node = net.row_object('wn_node','ST28360706')
demand_options = node.user_demand_options
```

{::/WSPRO}
