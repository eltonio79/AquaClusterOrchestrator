{ICM}

# WSSWMMRunBuilder

Used to create and modify SWMM runs. Runs can be created using an existing run as a template, or created from scratch by setting all of the required parameters.

You can create an instance using the `#new` method and call the remaining methods.

**Methods:**

{{toc}}

## [] (Get Key)

```ruby
#[(key)] ⇒ Any
```

`EXCHANGE`

Gets the value of a named run parameter.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Any     |             |

## []= (Set Key)

```ruby
#[(key)]=(value) ⇒ void
```

`EXCHANGE`

Sets the value of a named run parameter.

## create_new_run

```ruby
#create_new_run(run_group_id) ⇒ Boolean
```

`EXCHANGE`

Creates a new run in the specified run group, using the currently set parameters.

**Parameters**

| Name         | Type(s) | Description             |
| ------------ | ------- | ----------------------- |
| run_group_id | Integer | The id of a run group.  |
| Return       | Boolean | If the run was created. |

## get_run_mo

```ruby
#get_run_mo ⇒ WSRun?
```

`EXCHANGE`

Returns the `WSModelObject` associated with the most recent call to either `#load`, `#create_new_run`, or `#save`.

## list_parameters

```ruby
#list_parameters ⇒ Array<String>
```

`EXCHANGE`

Returns a list of available run parameters.

This is for information only, it does not return the current value of any parameter. These will be the same for all runs.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | Array\<String> |             |

## load

```ruby
#load(run) ⇒ Boolean
```

`EXCHANGE`

Loads the parameters from an existing run.

**Parameters**

| Name   | Type(s)                        | Description                                                           |
| ------ | ------------------------------ | --------------------------------------------------------------------- |
| run    | Integer, String, WSModelObject | The id, scripting path, or a wsmodelobject of the correct type (run). |
| Return | Boolean                        | If the run was successfully loaded.                                   |

## new

```ruby
#new ⇒ WSSWMMRunBuilder
```

`EXCHANGE`

Creates a new instance of this class.

**Parameters**

| Name   | Type(s)          | Description |
| ------ | ---------------- | ----------- |
| Return | WSSWMMRunBuilder |             |

## validate

```ruby
#validate(file) ⇒ Boolean
```

`EXCHANGE`

Validates the current run parameters, saving any validation errors to the specified file.

**Parameters**

| Name   | Type(s) | Description                                      |
| ------ | ------- | ------------------------------------------------ |
| file   | String  | A text file to save validation errors to.        |
| Return | Boolean | If the validation was successful with no errors. |
