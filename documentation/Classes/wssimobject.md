{ALL}

# WSSimObject

<!--
This page is mostly split into two sections - the first section is for ICM, the second is for WS Pro. Each shared method is documented twice because it's easier than having a bunch of extra conditional formatting per-method.
-->

[WSModelObject](./wsmodelobject.md) > [WSBaseNetworkObject](./wsbasenetworkobject.md) > [WSNumbatNetworkObject](./wsnumbatnetworkobject.md) > WSSimObject

{::ICM}

A read-only network with simulation results, representing an ICM Sim object, an ICM Risk Analysis Results object, or an ICM Risk Analysis Sim object. The Risk Analysis Results objects contain the results for a number of return periods and summary results. The Risk Analysis Sim objects contain only summary results.

The different return periods for the Risk Analysis Results objects correspond to the timesteps for regular simulations. The names of the methods reflect the usage for regular simulations i.e. to list the return periods for a risk analysis results object, you should use the `list_timesteps` method.

{::/ICM}

{::WSPRO}

A read-only network with simulation results.

{::/WSPRO}

**Methods:**

{{toc}}

{::ICM}

## list_max_results_attributes

```ruby
#list_max_results_attributes ⇒ Array<Array>
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Results, Risk Analysis Sim

This method returns attributes that can be exported using the [#max_results_binary_export](#max_results_binary_export) and [#max_results_csv_export](#max_results_csv_export) methods, and returns arrays corresponding to the tabs of the result export dialog in the UI.

```ruby
[
  ['Scalar', ['totfl', 'totout', 'totr', ...]],
  ['Node', ['flooddepth', 'floodvolume', 'flvol', ...]]
]
```

**Parameters**

| Name   | Type(s)      | Description |
| ------ | ------------ | ----------- |
| Return | Array\<Array> |             |

## list_results_attributes

```ruby
#list_results_attributes ⇒ Array<Array>
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Results

This method returns attributes that can be exported using the [#results_binary_export](#results_binary_export) and [#results_csv_export](#results_csv_export) methods, and returns arrays corresponding to the tabs of the result export dialog in the UI.

```ruby
[
  ['Node', ['flooddepth', 'floodvolume', 'flvol', ...]],
  ['Link', ['ds_depth', 'ds_flow', 'ds_froude', ...]]
]
```

**Parameters**

| Name   | Type(s)      | Description |
| ------ | ------------ | ----------- |
| Return | Array\<Array> |             |

## list_results_gis_export_tables

```ruby
#list_results_gis export_tables ⇒ Array
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Results, Risk Analysis Sim

Returns an array of the tables that may be exported to GIS using the [#results_gis_export](#results_gis_export) method.

- The results for 2D elements is `_2Delements`
- All links are combined into one GIS layer called `_links`

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Array   |             |

## list_timesteps

```ruby
#list_timesteps ⇒ Array
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Results, Risk Analysis Sim

For a normal simulation, this returns an array of the results timesteps for the simulation.

For a risk analysis results object, this returns an array of the return periods for the object.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Array   |             |

## max_flood_contours_export

```ruby
#max_flood_contours_export(format, ground_model, theme, filename) ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim

Exports the flood contours to files (GIS or ASCII). The ASCII format is the same as produced via the user interface.

**Parameters**

| Name         | Type(s)                        | Description                                                                                                                                                                                                                                                                                                                                |
| ------------ | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| format       | String                         | The fomat, one of `mif`, `tab`, `shp`, or `ascii` - as in the user interface, geodatabases are not supported.                                                                                                                                                                                                                              |
| ground_model | Integer, String, WSModelObject | The ground model, which must be a gridded ground model for an ascii export. can be the id (see description), scripting path, or a wsmodelobject of the correct type. if the `ground_model` id is negative then it represents a tin ground model, i.e. -6 represents the tin ground model with id 6, 9 is a gridded ground model with id 9. |
| theme        | Integer, String, WSModelObject | The theme to use for contours - can be the id, scripting path, or a wsmodelobject of the correct type.                                                                                                                                                                                                                                     |
| filename     | String                         | The file to export to.                                                                                                                                                                                                                                                                                                                     |

## max_results_binary_export

```ruby
#max_results_binary_export(selection, attributes, file) ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Results

Exports the maximum results (and other summary results) for the simulation in a binary file format - the format is documented elsewhere.

**Parameters**

| Name       | Type(s)                             | Description                                                                                                                                        |
| ---------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| selection  | WSModelObject, String, Integer, nil | A selection list object as a wsmodelobject of the correct type, a scripting path, or a model id. if `nil` then the whole network will be exported. |
| attributes | Array\<String>, nil                  | Attributes to export, e.g. from the `#list_results_attributes` method, if `nil` then all attributes are exported.                                  |
| file       | String                              | Filepath to export.                                                                                                                                |

## max_results_csv_export

```ruby
#max_results_csv_export(selection, attributes, folder) ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim

Exports the maximum results (and other summary results) for the simulation to .CSV files.

**Parameters**

| Name       | Type(s)                             | Description                                                                                                                                        |
| ---------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| selection  | WSModelObject, String, Integer, nil | A selection list object as a wsmodelobject of the correct type, a scripting path, or a model id. if `nil` then the whole network will be exported. |
| attributes | Array\<String>, nil                  | Attributes to export, e.g. from the `#list_results_attributes` method, if `nil` then all attributes are exported.                                  |
| folder     | String                              | Folder to export the .csv files.                                                                                                                   |

## raster_2d_export

```ruby
#raster_2d_export(arguments) ⇒ void
```

`EXCHANGE`, `UI`

Exports simulation results to a rasterized data format (TIF images).

The arguments hash contains the following keys:

| Key                    | Type           | Default | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ---------------------- | -------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Path                   | String         | ''      | Folder to export the .tif files.                                                                                                                       |
| SummaryMode            | Boolean        | false   | If this is set to true, only the maximum attribute results are exported. Otherwise, all the results.                                                   |
| Attributes             | Array\<String> |         | Array of strings with attribute names to be exported.                                                                                                  |
| UserUnits              | Boolean        | false   | If this is set to false, attributes will be exported using native units (meter's). Otherwise user units will be used (feet's).                         |
| Resolution             | Double         | 1.0     | Cell size of the raster in units chosen by 'UserUnits' argument.                                                                                       |
| AllTimestepsMode       | Boolean        | false   | If this is set to true, all simulation timesteps are exported. Otherwise, the single timestep passed by the 'Timestep' argument is exported.           |
| TimestepMultiplier     | Integer        | 1       | The step for exported timesteps. Used, when 'AllTimestepsMode' argument is true.                                                                       |
| Timestep               | Double         | 0.0     | Specific timestep value. Used, when 'AllTimestepsMode' argument is false.                                                                              |
| EPSG                   | Integer        | -1      | EPSG code for georeferencing (-1 value means unspecified).                                                                                             |

**Parameters**

| Name      | Type(s)                      | Description                                                                         |
| --------- | ---------------------------- | ----------------------------------------------------------------------------------- |
| arguments | Hash                         | Hash of parameters (see description above).                                         |

## results_binary_export

```ruby
#results_binary_export(selection, attributes, file) ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Results

Exports the results at each timestep of the simulation in a binary file format - the format is documented elsewhere.

**Parameters**

| Name       | Type(s)                             | Description                                                                                                                                        |
| ---------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| selection  | WSModelObject, String, Integer, nil | A selection list object as a wsmodelobject of the correct type, a scripting path, or a model id. if `nil` then the whole network will be exported. |
| attributes | Array\<String>, nil                  | Attributes to export, e.g. from the `#list_results_attributes` method, if `nil` then all attributes are exported.                                  |
| file       | String                              | Filepath to export.                                                                                                                                |

## results_csv_export

```ruby
#results_csv_export(selection, folder) ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim

Exports the simulation results in CSV format, corresponding to the CSV results export in the user interface.

If the results multiplier is set to 0, the CSV will be empty.

**Parameters**

| Name      | Type(s)                             | Description                                                                                                                                        |
| --------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| selection | WSModelObject, String, Integer, nil | A selection list object as a wsmodelobject of the correct type, a scripting path, or a model id. if `nil` then the whole network will be exported. |
| folder    | String                              | Folder to export the .csv files.                                                                                                                   |

## results_csv_export_ex

```ruby
#results_csv_export_ex(selection, attributes, folder) ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim

Similar to `#results_csv_export`, with an additional attributes parameter.

If the results multiplier is set to 0, the CSV will be empty.

**Parameters**

| Name       | Type(s)                             | Description                                                                                                                                        |
| ---------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| selection  | WSModelObject, String, Integer, nil | A selection list object as a wsmodelobject of the correct type, a scripting path, or a model id. if `nil` then the whole network will be exported. |
| attributes | Array\<String>, nil                  | Attributes to export, e.g. from the `#list_results_attributes` method, if `nil` then all attributes are exported.                                  |
| folder     | String                              | Folder to export the .csv files.                                                                                                                   |

## results_gis_export

```ruby
#results_gis_export(format, timesteps, options, folder) ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Results, Risk Analysis Sim

Exports simulation results to a GIS data format, similar to the equivalent options in the user interface.

The options for timesteps are:

- **nil** - this is the equivalent of the 'None' options when selecting timesteps in the UI i.e. it only makes sense if the options hash exports maximum results
- **String 'All'** - all timesteps, does not include maximum results unless included in the options hash
- **String 'Max'** - maximum results, alternative to including maximum results in the options hash
- **Integer** - timestep index, where 0 is the first timestep, and the last valid value is the number of timesteps - 1.
- **Array\<Integer>** - array of timestep indexes, which must all be valid and cannot contain duplicates

The options hash contains the following keys:

| Key                    | Type          | Default | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ---------------------- | ------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2DZoneSQL              | Array\<Array>  |         | Array of arrays, where the array contains:<br><br>0 - String - The name of the field to be exported<br>1 - String - The SQL expression<br>2 - Integer - Optional value between 0-9 inclusive, representing the number of decimal places. Default is 2.<br> <br>The default is not to export any extra fields for 2D elements.                                                                                                                                                                                                |
| AlternativeNaming      | Boolean       |         | If this is set then the subfolders / feature datasets used for the export are given simpler but less attractive names which may be helpful if the aim is process the files with software rather than to have a user select and open them in a GIS package.<br> <br>The simple names are `<model object id>_<timestep>` with the timesteps numbered from zero as with the timesteps parameter of the method and with `<model object id>_Max` for the maxima.<br><br>The default is to use the same naming convention as the UI. |
| ExportMaxima           | Boolean       | false   | If this is set to true the maximum results are exported.                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Feature Dataset        | String        | ''      | For GeoDatabases, the name of the feature dataset.                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Tables                 | Array\<String> |         | Array of table names from `#list_results_gis_exports_table`. Must all be valid, and cannot contain duplicates.                                                                                                                                                                                                                                                                                                                                                                                                               |
| Threshold              | Float         |         | The depth threshold below which a 2D element is not exported. This is the equivalent of checking the check-box in the UI and entering a value.<br><br>The default is to behave as though the check-box is unchecked i.e. all elements are exported.                                                                                                                                                                                                                                                                         |
| UseArcGISCompatibility | Boolean       | false   | This is the equivalent of selecting the check-box in the UI.                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name      | Type(s)                              | Description                                                                         |
| --------- | ------------------------------------ | ----------------------------------------------------------------------------------- |
| format    | String                               | Export format, one of `shp`, `tab`, `mif`, or `gdb`.                                |
| timesteps | String, Integer, Array\<Integer>, nil | See description.                                                                    |
| options   | Hash, nil                            | Hash of options (see description) or nil to use defaults.                           |
| folder    | String                               | The base folder for files to be exported, or path to the `.gdb` if format is `gdb`. |

## results_path

```ruby
#results_path ⇒ String
```

`EXCHANGE`

Returns full path for results.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## run

```ruby
#run ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim

Runs (or re-runs) the simulation. This will block the current thread i.e. script execution will halt while this task finishes.

The simulation will be run on the current machine.

## run_ex

```ruby
#run_ex(*args) ⇒ void
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Sim

This method is similar to `#run`, and is also a blocking operation. There are two versions of this method.

### Single Parameter (Options Hash)

```ruby
#run_ex(options) ⇒ void
```

This version takes a single parameter, which is an options hash containing the following keys:

| Name              |  Type   |   Default   | Description                                                                                                                                                      |
| ----------------- | :-----: | :---------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Server            | String  |     \*      | The name of the server the simulation may run on, or one of:<br><br>- . (period) means the local server / computer<br>- \* (asterisk) means any available server |
| Threads           | Integer |      0      | The number of threads to use, 0 indicates as many threads as possible.                                                                                           |
| SU                | Boolean |    false    | If you are using InfoWorks One you must set this to true.                                                                                                        |
| ResultsOnServer   | Boolean |    true     | Whether to store results on server. False stores results locally.                                                                                                |
| DownloadSelection | String  | ALL_RESULTS | May be "NO_RESULTS", "SUMMARY_RESULTS" or "ALL_RESULTS". Only applies to cloud databases.                                                                        |

**Parameters**

| Name    | Type(s) | Description                          |
| ------- | ------- | ------------------------------------ |
| options | Hash    | Options Hash. See method description |

### Two Parameters

```ruby
#run_ex(server, number_of_threads) ⇒ void
```

**Parameters**

| Name              | Type(s) | Description                                                                                                                               |
| ----------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| server            | String  | The name of the server the simulation may run on, or '.' (period) means the local machine, or '\*' (asterisk) means any available server. |
| number_of_threads | Integer | The number of threads to use, 0 indicates as many threads as possible.                                                                    |

## status

```ruby
#status ⇒ String
```

`EXCHANGE`, `UI`

**Supported Types:** ICM Sim

Returns the status of a simulation.

To monitor for completion of a simulation, the recommended approach is to use the `#wait_for_jobs` method.

**Parameters**

| Name   | Type(s)     | Description                                                       |
| ------ | ----------- | ----------------------------------------------------------------- |
| Return | String, nil | Simulation status, one of `none`, `active`, `success`, or `fail`. |

## success_substatus

```ruby
#success_substatus ⇒ String
```

`EXCHANGE`

**Supported Types:** ICM Sim

Returns the simulation substatus, if the sim was successful.

**Parameters**

| Name   | Type(s)     | Description                                                                                                              |
| ------ | ----------- | ------------------------------------------------------------------------------------------------------------------------ |
| Return | String, nil | Simulation substatus, one of `incomplete`, `warnings`, or `ok` - will return `nil` if the simulation was not successful. |

## timestep_count

```ruby
#timestep_count ⇒ Integer
```

`EXCHANGE`

**Supported Types:** ICM Sim, Risk Analysis Results, Risk Analysis Sim

Returns the number of results timesteps in the simulation.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

{::/ICM}

{::WSPRO}

## forced_fire_flow_csv_export

```ruby
#forced_fire_flow_csv_export(file_name) ⇒ void
```

`EXCHANGE`, `UI`

Exports a forced fire flow report to a CSV file.

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| file_name   | String	 | Path to the output CSV file.  |

## gmr_summary_export

```ruby
#gmr_summary_export(folder) ⇒ void
```

`EXCHANGE`, `UI`

In the folder, a CSV file will be written for each summary report that has been configured.

## hyd_test_report_csv_export

```ruby
#hyd_test_report_csv_export(file_name) ⇒ void
```

`EXCHANGE`, `UI`

Exports a hydrant testing report to a CSV file.

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| file_name   | String	 | Path to the output CSV file.  |

## list_results_attributes

```ruby
#list_results_attributes ⇒ Array<Array>
```

`EXCHANGE`, `UI`

Returns attributes that can be exported using the [#results_binary_export](#results_binary_export) method, and returns arrays corresponding to the tabs of the result export dialog in the UI.

```ruby
[
	["Scalar", ["tdemand", "xdemand", "xferin", "xferout"]], 
	["Node", ["demand", "head", "pressure", "status"]], 
	["Link", ["flow", "headloss", "status"]]
]
```

**Parameters**

| Name   | Type(s)      | Description |
| ------ | ------------ | ----------- |
| Return | Array\<Array> |             |

## list_results_gis_export_tables

```ruby
#list_results_gis_export_tables ⇒ Array<String>
```

`EXCHANGE`, `UI`

Returns an array of the tables that may be exported to GIS using the `#results_gis_export` method.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | Array\<String> |             |

## list_timesteps

```ruby
#list_timesteps ⇒ Array<DateTime>
```

`EXCHANGE`, `UI`

Returns an array of the timesteps for the simulation.

## results_binary_export

```ruby
#results_binary_export(selection, attributes, file) ⇒ void
```

`EXCHANGE`, `UI`

Exports the results at each timestep of the simulation in a binary file format - the format is documented elsewhere.

**Parameters**

| Name       | Type(s)                             | Description                                                                                                                                        |
| ---------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| selection  | WSModelObject, String, Integer, nil | A selection list object as a wsmodelobject of the correct type, a scripting path, or a model id. if `nil` then the whole network will be exported. |
| attributes | Array\<String>, nil                  | Attributes to export, e.g. from the `#list_results_attributes` method, if `nil` then all attributes are exported.                                  |
| file       | String                              | Filepath to export.                                                                                                                                |

## results_csv_export

```ruby
#results_csv_export(selection, folder) ⇒ void
```

`EXCHANGE`, `UI`

Exports the simulation results in CSV format, corresponding to the CSV results export in the user interface.

**Parameters**

| Name      | Type(s)                             | Description                                                                                                                                        |
| --------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| selection | WSModelObject, String, Integer, nil | A selection list object as a wsmodelobject of the correct type, a scripting path, or a model id. if `nil` then the whole network will be exported. |
| folder    | String                              | Folder to export the .csv files.                                                                                                                   |

## results_csv_export_ex

```ruby
#results_csv_export_ex(selection, folder, options) ⇒ void
```

`EXCHANGE`, `UI`

Similar to `#results_csv_export`, with an additional options parameter.

The options hash contains the following key:

| Key           | Type    | Default | Description                                                   |
| ------------- | ------- | ------- | ------------------------------------------------------------- |
| Group By Time | Boolean | false   | Results are grouped by time, similar to the option in the UI. |

**Parameters**

| Name      | Type(s)                             | Description                                                                                                                                        |
| --------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| selection | WSModelObject, String, Integer, nil | A selection list object as a wsmodelobject of the correct type, a scripting path, or a model id. if `nil` then the whole network will be exported. |
| folder    | String                              | Folder to export the .csv files.                                                                                                                   |
| options   | Hash                                | Options hash, see description.                                                                                                                     |

## results_gis_export

```ruby
#results_gisexport(format, timesteps, options, folder) ⇒ void
```

`EXCHANGE`, `UI`

Exports simulation results to a GIS data format, similar to the equivalent options in the user interface.

The options for timesteps are:

- **nil** - this is the equivalent of the 'None' options when selecting timesteps in the UI
- **String 'All'** - all timesteps, does not include maximum results unless included in the options hash
- **Integer** - timestep index, where 0 is the first timestep, and the last valid value is the number of timesteps - 1.
- **Array\<Integer>** - array of timestep indexes, which must all be valid and cannot contain duplicates

The options hash contains the following keys:

| **Key**           | **Type**      | **Description**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ----------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AlternativeNaming | Boolean       | If this is set then the subfolders / feature datasets used for the export are given simpler but less attractive names which may be helpful if the aim is process the files with software rather than to have a user select and open them in a GIS package.<br> <br>The simple names are `<model object id>_<timestep>` with the timesteps numbered from zero as with the timesteps parameter of the method and with `<model object id>_Max` for the maxima.<br><br>The default is to use the same naming convention as the UI. |
| Feature Dataset   | String        | For GeoDatabases, the name of the feature dataset.<br><br>The default is an empty string.                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| Tables            | Array\<String> | Array of table names from `#list_results_GIS_exports_table`. Must all be valid, and cannot contain duplicates.                                                                                                                                                                                                                                                                                                                                                                                                               |

**Parameters**

| Name      | Type(s)                              | Description                                                                         |
| --------- | ------------------------------------ | ----------------------------------------------------------------------------------- |
| format    | String                               | Export format, one of `shp`, `tab`, `mif`, or `gdb`.                                |
| timesteps | String, Integer, Array\<Integer>, nil | See description.                                                                    |
| options   | Hash, nil                            | Hash of options (see description) or nil to use defaults.                           |
| folder    | String                               | The base folder for files to be exported, or path to the `.gdb` if format is `gdb`. |


## slr_report

```ruby
#slr_report(options) ⇒ Hash
```

`EXCHANGE`, `UI`

Creates a service level report and returns it as a hash.

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| options	   | Hash	 | Options hash  |


**Hash Options**

| Key    				 | Type     | Defaults	| Notes	|
| ---------------------- | ----------- | -------- | --------------|
| min_pressure_threshold		  | Float     | 15.0 | Minimum pressure threshold |
| max_pressure_limit		 	    | Float     | 0.0  | Maximum pressure threshold |
| min_pressure_duration	      | Integer   | 30   | Minimum pressure duration (min)  |
| max_pressure_duration	      | Integer	  | 30   | Maximum pressure duration (min)  |
| demand_reduction            | Float	    | 0.0   | Demand reduction           |
| demand_efficiency	   	      | Float     | 0.0   | Demand efficiency     |
| pressure_change_min_threshold	  	| Float  | 20.0   | Pressure change minimum threshold           |
| pressure_change_max_threshold	    | Float  | 20.0   | Pressure change maximum threshold      |
| pressure_change_min_duration	    | Float  | 30.0  	| Pressure change minimum duration (min)	 |
| pressure_change_max_duration		  | Float  | 30.0   | Pressure change maximum duration (min)    |
| report_on_customer_points 		  	| Boolean  | false   | Report on customer points           |
| compare_at_highest_property		   	| Boolean  | false   | Compare at highest property    |
| include_demands	 		              | Boolean  | true    | Include demands            |
| include_nodes_without_demand      | Boolean  | false   | Include nodes without demand          |
| show_clusters     	              | Boolean  | false   | Show clusters        |


## slr_report_json

```ruby
#slr_report_json(options) ⇒ String
```

`EXCHANGE`, `UI`

Same as [slr_report](#slr_report) but this method returns a JSON string rather than a hash.

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| options  | Hash	        | Options hash  |


## slr_report_json_export

```ruby
#slr_report_json_export(options, file_name) ⇒ void
```

`EXCHANGE`, `UI`

Same as [slr_report_json](#slr_report_json) but this method exports to a file.

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| options   | Hash	 | Options hash  |
| file_name | String | Path to the output file  |


## status

```ruby
#status ⇒ String
```

`EXCHANGE`, `UI`

Returns the status of a simulation.

To monitor for completion of a simulation, the recommended approach is to use the `#wait_for_jobs` method.

**Parameters**

| Name   | Type(s) | Description                                     |
| ------ | ------- | ----------------------------------------------- |
| Return | String  | One of `none`, `active`, `success`, or `fail`.  |

## success_substatus

```ruby
#success_substatus ⇒ String?
```

`EXCHANGE`, `UI`

Returns the simulation substatus if the sim was successful, one of `Incomplete`, `Warnings`, or `OK`. Will be `nil` if the sim was unsuccessful.

## timestep_count

```ruby
#timestep_count ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of result timesteps in the simulation. This will match the length of the array returned by `#list_timesteps`.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

{::/WSPRO}
