{WSPRO}

# WSRunScheduler

Used to create and modify runs. Runs can be modified in place (if they are experimental), created from scratch by setting all of the required parameters, or created using an existing run as a template.

To use this class you must first create an instance of it using the [#new](#new) method, and then call the remaining methods in the correct order. A simple example is provided here:

```ruby
database = WSApplication.open()

model_group = database.model_object_from_type_and_id('Catchment Group', 2)
run_group = model_group.new_model_object('Wesnet Run Group', 'New Runs')

network = database.model_object_from_type_and_id('Geometry', 9)
control = database.model_object_from_type_and_id('Control', 10)
ddg = database.model_object_from_type_and_id('Demand Diagram', 12)

run_options = {
  'ro_s_run_title' => network.name,
  'ro_l_run_type ' => 0,
  'ro_b_experimental' => true,
  'ro_l_geometry_id' => network.id,
  'ro_l_geometry_commit_id' => network.latest_commit_id,
  'ro_l_control_id' => control.id,
  'ro_l_control_commit_id' => control.latest_commit_id,
  'ro_l_demand_diagram_id' => ddg.id,
  'ro_l_max_iterations' => 99,
  'ro_dte_start_date_time' => DateTime.new(2001, 1, 1),
  'ro_dte_end_date_time' => DateTime.new(2001, 1, 2),
  'ro_l_time_step' => 15,
  'ro_b_results_on_server' => false,
  'ro_f_computational_accuracy' => 1.0
}

run_scheduler = WSRunScheduler.new()
run_scheduler.create_new_run(run_group.id)
run_scheduler.set_parameters(run_options)
raise 'Failed to validate Run' if !run_scheduler.validate(nil)
raise 'Failed to save Run' if !run_scheduler.save(false)
run = run_scheduler.get_run_mo
```

**Methods:**

{{toc}}

## create_new_run

```ruby
#create_new_run(run_group_id) ⇒ Boolean
```

`EXCHANGE`, `UI`

Creates a new run in the specified run group, using the current parameters.

**Parameters**

| Name         | Type(s) | Description                                                                                |
| ------------ | ------- | ------------------------------------------------------------------------------------------ |
| run_group_id | Integer | The id of a run group i.e. a [WSModelObject](wsmodelobject.md) of type `Wesnet Run Group`. |
| Return       | Boolean | If the run was created.                                                                    |

## get_run_mo

```ruby
#get_run_mo ⇒ WSRun?
```

`EXCHANGE`, `UI`

Returns the [WSRun](wsrun.md) associated with the most recent call to [#load](#load), [#create_new_run](#create_new_run), or [#save](#save).

## load

```ruby
#load(run_id) ⇒ Boolean
```

`EXCHANGE`, `UI`

Loads an existing run and its parameters.

If the run is experimental (has the parameter `ro_b_experimental` set to `true`) the run can be modified and saved in-place using the [#save](#save) method. Otherwise the parameters can be modified but the run must be saved with a different title - either by changing the run parameter `ro_s_run_title`, or using the auto-rename option of the [#save](#save) method.

**Parameters**

| Name   | Type(s) | Description                                                                                    |
| ------ | ------- | ---------------------------------------------------------------------------------------------- |
| run_id | Integer | The model id of an existing run i.e. a [WSModelObject](wsmodelobject.md) of type `Wesnet Run`. |
| Return | Boolean | If the load was successful.                                                                    |

## new

```ruby
#new ⇒ WSRunScheduler
```

`EXCHANGE`, `UI`

Creates a new instance of this class.

Not to be confused with the [#create_new_run](#create_new_run) method, which is used to create a [WSRun](wsrun.md) object.

Note: before creating an instance of this class, your script must access a [WSDatabase](wsdatabase.md) object - failing to do so can cause the Exchange process to crash.

**Parameters**

| Name   | Type(s)        | Description |
| ------ | -------------- | ----------- |
| Return | WSRunScheduler |             |

## save

```ruby
#save(auto_rename) ⇒ Boolean
```

`EXCHANGE`, `UI`

Saves the run, including any changes to the run parameters.

This method can be used if the run has already been created, e.g. after [#create_new_run](#create_new_run) has been called, or if the current run was loaded with [#load](#load).

If the run is read-only (i.e. has the parameter `ro_b_experimental` set to `false`, and has been run already) then the `auto_rename` parameter can be used to create a new run with a unique name automatically, similar to the behavior in the user interface. Otherwise the run cannot be updated, and attempting to save will raise an exception.

**Parameters**

| Name        | Type(s) | Description                                                                               |
| ----------- | ------- | ----------------------------------------------------------------------------------------- |
| auto_rename | Boolean | If true, will create a new renamed run if the loaded run is read-only (not experimental). |
| Return      | Boolean | If the save was successful.                                                               |

**Exceptions**

- if the loaded run is read-only (i.e. has the parameter `ro_b_experimental` set to `false`, and has been run already) and `auto_rename` is false

## save_keep_results

```ruby
#save_keep_results(auto_rename) ⇒ Boolean
```

`EXCHANGE`, `UI`

Saves the run, including any changes to the run parameters. Unlike [#save](#save) this will not delete existing results.

**Parameters**

| Name        | Type(s) | Description                                                                               |
| ----------- | ------- | ----------------------------------------------------------------------------------------- |
| auto_rename | Boolean | If true, will create a new renamed run if the loaded run is read-only (not experimental). |
| Return      | Boolean | If the save was successful.                                                               |

Exceptions

- if the loaded run is read-only (i.e. has the parameter `ro_b_experimental` set to `false`, and has been run already) and `auto_rename` is false

## set_parameters

```ruby
#set_parameters(hash) ⇒ void
```

`EXCHANGE`, `UI`

Updates the run parameters from the hash. Any run parameters not in the hash are left at their current value (or defaults).

The full list of parameters can be found in the appendix, and will vary depending on the run type and whether you want to modify any default settings.

```ruby
params = {
  'ro_s_run_title' => 'MyRun',
  'ro_l_run_type ' => 0
}

run_scheduler.set_parameters(params)
```

## validate

```ruby
#validate(file) ⇒ Boolean
```

`EXCHANGE`, `UI`

Validates the current run parameters, saving any validation errors to the specified file. Will return true if the validation was successful with no errors.

**Parameters**

| Name   | Type(s) | Description                                      |
| ------ | ------- | ------------------------------------------------ |
| file   | String  | A text file to save validation errors to.        |
| Return | Boolean | If the validation was successful with no errors. |

## wsma

```ruby
#wsma(params) ⇒ String
```

`EXCHANGE`

This method is used to launch and cancel runs via the WSMarshaller. Unlike the [WSRun.run](wsrun.md) method, this will not block the Ruby script, allowing for more complex automation including batch simulations.

The parameters hash contains the following common keys:

| Name                 | Type    | Required | Default | Description                                                                                   |
| -------------------- | ------- | -------- | ------- | --------------------------------------------------------------------------------------------- |
| operation            | Integer | No       | 0       | 0 for a new run, 1 to cancel existing run(s)                                                  |
| action_name          | String  | Yes      |         |                                                                                               |
| master_database_guid | String  | Yes      |         | The database GUID, which can be accessed via the [WSDatabase.guid](wsdatabase.md) method |

### Launching New Run(s)

A single call to this method can contain multiple jobs, where each job is a run that will be performed in series (i.e. one at a time, in order). For parallel simulations, you will need multiple calls to the method.

When the `operation` key is set to `0` (new run), the parameters hash can contain the following additional keys:

| Name              | Type    | Required | Default | Description                                                                                                                                                                                                                |
| ----------------- | ------- | -------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| run_name          | String  | No       |         | The name seen in the user interface                                                                                                                                                                                        |
| run_on            | String  | Yes      | '.'     | The computer to run on, equivalent to the 'Run On' property of the run scheduler window in the User Interface. Can use '.' for 'This Computer' or '\*' for 'Any Computer', or the name of a specific agent or agent group. |
| max_slots         | Integer | No       | 0       | Limit number of slots utilized by the run, 0 to use agent defaults.                                                                                                                                                        |
| build_id          | Integer | Yes      |         | A unique integer used to identify this job later, e.g. when cancelling it                                                                                                                                                  |
| results_directory | String  | No       |         | If unset, will default to the results location implied in the run settings e.g. on server, or local                                                                                                                        |

The parameters hash then contains the following keys per job, formatted as `job0_alias`, `job1_alias` etc:

| Name  | Type    | Required | Description                                      |
| ----- | ------- | -------- | ------------------------------------------------ |
| alias | String  | Yes      | Name of the job that will appear in the log file |
| ident | String  | Yes      | The model id of the run                          |
| type  | Integer | Yes      | Use `0`                                          |

**Examples**

```ruby
params = {
  'operation' => 0,
  'action_name' => 'MyRuns',
  'master_database_guid' => database.guid,
  'build_id' => 1337,
  'job0_alias' => 'Badger',
  'job0_ident' => 42,
  'job0_type' => 0,
  'job1_alias' => 'Penguin',
  'job1_ident' => 96,
  'job1_type' =>0
}
```

### Cancelling Run(s)

You may only cancel run(s) launched via this method, which are identified by their unique `build_id`. You cannot cancel runs that were started from the user interface.

When the `operation` key is set to `1` (cancel runs), the parameters hash can contain the following additional keys:

| Name      | Type   | Required | Default | Description                                                |
| --------- | ------ | -------- | ------- | ---------------------------------------------------------- |
| build_ids | String | Yes      |         | `build_id`s to cancel, which can be a comma separated list |
| reason    | String | No       |         |                                                            |

**Examples**

```ruby
params = {
  'operation' => 1,
  'action_name' => 'CancellingMyRuns',
  'master_database_guid' => database.guid,
  'build_ids' => '1337,451',
  'reason' => 'Changed my mind'
}
```

### Return String

The return string is a combination of a success state, and a message if there is an error. The first character is either 0 (failure) or 1 (success), and the remaining characters are a message.

**Examples**

```ruby
return = run_scheduler.wsma(params)
success = return[0] == '1'
message = return[1..-1]
```

**Parameters**

| Name   | Type(s) | Description                                                                                                                                |
| ------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| params | Hash    | A hash of parameters, see method description.                                                                                              |
| Return | String  | A combination string where the first character is either 0 or 1 to indicate failure or success, and any remaining characters is a message. |
