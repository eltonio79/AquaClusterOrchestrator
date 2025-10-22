{WSPRO}

# WSDemandAllocation

Used to allocate customer points to pipes in the network. The options and behavior of this class broadly match the static demand allocation tool in the user interface.

To use the methods of this class, you need to create an instance using the `#new` method and call the remaining methods.

```ruby
network = WSApplication.current_network

allocator = WSDemandAllocation.new()
allocator.network = network
allocator.options = {'max_dist_to_pipe_native' => 200.00, 'max_pipe_diameter_native' => 200.00}
allocator.allocate
```

**Methods:**

{{toc}}

## allocate

```ruby
#allocate ⇒ void
```

`EXCHANGE`, `UI`

Performs the allocation. Will raise an exception if the allocation fails.

## demand_diagram= (Set)

```ruby
#demand_diagram=(ddg) ⇒ void
```

`EXCHANGE`, `UI`

Optionally sets the demand diagram.

**Parameters**

| Name | Type(s)       | Description                |
| ---- | ------------- | -------------------------- |
| ddg  | WSModelObject | The demand diagram to use. |

## network= (Set)

```ruby
#network=(network) ⇒ void
```

`EXCHANGE`, `UI`

Sets the network to allocate demand for.

**Parameters**

| Name    | Type(s)                           | Description                                     |
| ------- | --------------------------------- | ----------------------------------------------- |
| network | [WSOpenNetwork](wsopennetwork.md) | The network to use, must be of type `geometry`. |

## new

```ruby
#new ⇒ WSDemandAllocation
```

`EXCHANGE`, `UI`

Creates a new instance of this class.

## options

```ruby
#options ⇒ Hash
```

`EXCHANGE`, `UI`

Gets the current option, including all default values.

## options= (Set)

```ruby
#options=(hash) ⇒ void
```

`EXCHANGE`, `UI`

Sets the options to use for the allocation. The options hash can contain the following keys:

| Key                             |  Type   | Default |
| ------------------------------- | :-----: | :-----: |
| allocate_demand_unallocated     | Boolean |  true   |
| allocated_flag                  | String  |         |
| exclude_allocations_flag        | String  |         |
| exclude_allocations_with_flags  | Boolean |  false  |
| ignore_reservoirs               | Boolean |  true   |
| max_dist_along_pipe_native      |  Float  |   0.0   |
| max_dist_to_pipe_native         |  Float  |   0.0   |
| max_distance_steps              | Integer |    1    |
| max_pipe_diameter_native        |  Float  |   0.0   |
| max_properties_per_node         | Integer |    0    |
| node_within_cp_polygon          | Boolean |  false  |
| only_pipes_within_polygon       | Boolean |         |
| only_to_nearest_node            | Boolean |  true   |
| only_to_selected_nodes          | Boolean |  false  |
| reallocate_demand_average       | Boolean |  false  |
| reallocate_demand_direct        | Boolean |  false  |
| reallocate_demand_property      | Boolean |  false  |
| remove_demand_average           | Boolean |  false  |
| remove_demand_direct            | Boolean |  false  |
| remove_demand_property          | Boolean |  false  |
| restrict_allocations_to_polygon | Boolean |         |
| use_connection_points           | Boolean |  false  |
| use_nearest_pipe                | Boolean |  true   |
| use_smallest_pipe               | Boolean |  false  |
