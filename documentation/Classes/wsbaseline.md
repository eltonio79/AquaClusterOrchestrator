{WSPRO}

# WSBaseline

[WSModelObject](./wsmodelobject.md) > [WSBaseNetworkObject](./wsbasenetworkobject.md) > [WSNumbatNetworkObject](./wsnumbatnetworkobject.md) > WSBaseline.

**Methods:**

{{toc}}

## create_run_info

```ruby
#create_run_info(start_time, duration, name, comment) ⇒ Integer
```

`EXCHANGE`, `UI`

Creates a new IWLive Run Info object. A new group is also created if required.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| start_time | DateTime  | The simulation start time  |
| duration | Float  | Duration in days  |
| name | String  | The run name  |
| comment | String  | Comment  |
| Return | Integer  | The IWLive Run Info ID  |

## enable_operator= (Set)

```ruby
#enable_operator=(bool) ⇒ void
```

`EXCHANGE`, `UI`

Enables the Baseline in IWLive Pro operator.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| bool | Boolean  |  |

## enable_operator?

```ruby
#enable_operator? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns whether the Baseline is enabled in IWLive Pro operator.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| bool | Boolean  |  |


## enable_server= (Set)

```ruby
#enable_server=(bool) ⇒ void
```

`EXCHANGE`, `UI`

Enables the Baseline in IWLive Pro server.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| bool | Boolean  |  |

## enable_server?

```ruby
#enable_server? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns whether the Baseline is enabled in IWLive Pro server.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| bool | Boolean  |  |

## set_default_sim_id

```ruby
#set_default_sim_id(id) ⇒ nil
```

`EXCHANGE`, `UI`

Sets the default simulation in the Baseline.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| id | Integer  | The Simulation ID |
| Return | nil  | |


## set_live_data_id 

```ruby
#set_live_data_id (id, commit) ⇒ nil
```

`EXCHANGE`, `UI`

Sets the live data configuration in the Baseline.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| id | Integer  | The Live Data Configuration ID |
| commit | Integer  | The commit for the live data configuration |
| Return | nil  | |


## update_control

```ruby
#update_control(run_info_id, control_id) ⇒ Boolean
```

`EXCHANGE`, `UI`

Updates a Control from the live data stored in the IWLive Run Info object.

**Parameters**

| Name     | Type(s) | Description                          |
| -------- | ------- | ------------------------------------ |
| run_info_id | Integer  | The IWLive Run Info ID |
| control_id | Integer  | The Control ID |
| Return | Boolean  | True if successful |

## update_from_live_data

```ruby
#update_from_live_data(run_info_id) ⇒ Boolean
```

`EXCHANGE`, `UI`

Updates the IWLive Run Info object from live data.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| run_info_id | Integer  | The IWLive Run Info ID |
| Return | Boolean  | True if successful , false if failed |

**Example**

Here is an example of using the Baseline functions:

```ruby
require 'date'

iwdb = WSApplication.open
baseline=iwdb.model_object_from_type_and_id('Baseline', 35)
baseline.set_live_data_id(36, 2)
baseline.set_default_sim_id(34)
run_info_id = baseline.create_run_info(DateTime.new(1998,10,1), 1.0, 'My Run Info', 'My Comment')
baseline.update_from_live_data(run_info_id)
baseline.update_control(run_info_id, 8)
```