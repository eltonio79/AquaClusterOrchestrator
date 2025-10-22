{WSPRO}

# WSRun

[WSModelObject](./wsmodelobject.md) > WSRun

A hydraulic run, which can be generated from an instance of [WSRunScheduler](wsrunscheduler.md).

**Methods:**

{{toc}}

## release

```ruby
#release ⇒ void
```

`EXCHANGE`

Releases (removes) the run from the queue, this is optional and can be called after the run has finished.

## run

```ruby
#run ⇒ void
```

`EXCHANGE`, `UI`

Performs the run.

This method will block the current thread, meaning that the script will halt until the run has completed. An alternative method for performing runs asynchonously is the [WSRunScheduler.wsma](wsrunscheduler.md#wsma) method.

## run_control_id

```ruby
#run_control_id ⇒ Integer?
```

`EXCHANGE`, `UI`

Returns the current control model ID.

## run_control_id= (Set)

```ruby
#run_control_id=(id) ⇒ void
```

`EXCHANGE`, `UI`

Sets the control model ID, if the run is not read-only.

**Parameters**

| Name | Type(s) | Description           |
| ---- | ------- | --------------------- |
| id   | Integer | The control model id. |

## run_demand_diagram_id

```ruby
#run_demand_diagram_id ⇒ Integer?
```

`EXCHANGE`, `UI`

Returns the current demand diagram ID.

## run_demand_diagram_id (Set)

```ruby
#run_control_id=(id) ⇒ void
```

`EXCHANGE`, `UI`

Sets the demand diagram ID, if the run is not read-only.

**Parameters**

| Name | Type(s) | Description           |
| ---- | ------- | --------------------- |
| id   | Integer | The demand diagram ID |

## run_network_id

```ruby
#run_network_id ⇒ Integer?
```

`EXCHANGE`, `UI`

Returns the current network model ID.

## run_network_id= (Set)

```ruby
#run_network_id=(id) ⇒ void
```

`EXCHANGE`, `UI`

Sets the network model ID, if the run is not read-only.

**Parameters**

| Name | Type(s) | Description           |
| ---- | ------- | --------------------- |
| id   | Integer | The network model id. |

## run_scenario_ids

```ruby
#run_scenario_ids { ... } ⇒ String
```

`EXCHANGE`, `UI`

Returns the current scenario names.

**Example**
```ruby
run.run_scenario_ids { |scenario| puts scenario}
```

## run_scenario_ids= (Set)

```ruby
#run_scenario_ids=(scenarios) ⇒ void
```

`EXCHANGE`, `UI`

Sets the scenarios used in the run, if the run is not read-only.

**Parameters**

| Name      | Type(s)               | Description                                     |
| --------- | --------------------- | ----------------------------------------------- |
| scenarios | String, Array\<String> | A single scenario id, or array of scenario ids. |
