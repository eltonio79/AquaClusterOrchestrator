{ALL}

# WSOpenNetwork

An open network. An open network allows access to the network contents, similar to opening the network as a grid or GeoPlan in the UI.

Note: a network in this context is not the same as a 'network' in the user interface.

**Methods:**

{{toc}}

## add_scenario

```ruby
#add_scenario(name, based_on, notes) ⇒ void
```

`EXCHANGE`, `UI`

Adds a new scenario to the network.

```ruby
network.add_scenario('MyNewScenario', nil, 'Some notes...')
```

**Parameters**

| Name     | Type(s)     | Description                                        |
| -------- | ----------- | -------------------------------------------------- |
| name     | String      | Name of the new scenario.                          |
| based_on | String, nil | The name of the scenario to use as a base, if any. |
| notes    | String      | Notes or description for this scenario.            |

{::ICM}

## cancel_mesh_job

```ruby
#cancel_mesh_job(job_id) ⇒ void
```

`EXCHANGE`

Cancels a mesh job.

**Parameters**

| Name   | Type(s) | Description                                            |
| ------ | ------- | ------------------------------------------------------ |
| job_id | Integer | The job id from the [#mesh_async](#mesh_async) method. |

{::/ICM}

## clean_up_network

```ruby
#clean_up_network(options) ⇒ void
```

`EXCHANGE`, `UI`

Cleans up a network

**Parameters**

| Name   | Type(s) | Description          |
| ------ | ------- | -------------------- |
| options | Hash | options hash |

**Hash Options**

| Key    				 | Type     | Defaults	| Notes	|
| ---------------------- | ----------- | -------- | --------------|
| vertex_only		 | Boolean     | true | Vertex only |
| loop_clean	 	 | Boolean     | true | Loop clean-up |
| valve_check	   	 | Boolean     | true | Valve check  |
| link_check	 | Boolean	   | true | Link check  |
| zerolen_check  | Boolean	   | true   | Zero length check           |
| multi_link	   	| Boolean  | true   | Include multi-link nodes     |
| hidden_nodes	 	| Boolean  | true   | Include hidden nodes           |
| use_digdef	    | Boolean  | false  | Use digitisation defaults      |
| connect_pipes_vertex	| Boolean  | true  	 | Connect pipe vertices	 |
| keep_isolated_assets	| Boolean  | false   | Keep isolated assets     |
| proximity 			| Double   | 1.0   | Pipe proximity           |
| vertex_proximity	   	| Double   | 0.005   | Pipe vertex proximity    |
| flag	 		| String  |    | Edit flag            |
| man_field     | String  |    | Manual update flag field           |
| man_val     	| String  |    | Manual update flag value         |
| log_filename	| String  |    | Path to log file		      |
| add_node_type	| String  |    | Add node type		      |

## clear_selection

```ruby
#clear_selection ⇒ void
```

`EXCHANGE`, `UI`

Clears the current selection, i.e. any WSRowObjects that are currently selected will be deselected.

{::WSPRO}

## compare

```ruby
#compare(other, file_name, options) ⇒ void
```

`EXCHANGE`, `UI`

Compares two networks and outputs the result to a file.

```ruby
iwdb = WSApplication.current_database
net = WSApplication.current_network.model_object
file_name = "C:/temp/compare.txt"
other_network = iwdb.model_object_from_type_and_id('Geometry',1771)
options = {
  "Version" => 0,
  "Other Version" => 0,
  "Scenario" => "Base",
  "Selection List ID" => 1683,
  "Select Changed Objects" => false,
  "Ignore Flags" => false,
  "Ignore Defaults" => false,
  "Ignore Unique IDs" => false,
  "Use Display Precision" => true,
  "Output Format" => "TEXT"
}
net.compare(other_network, file_name, options)
WSApplication.open_text_view('Compare', file_name, false)
```

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| other       | WSModelObject	| Other network for comparison, or nil to show uncommitted changes.	|
| file_name   | String    		| Output file |
| options     | Hash			| Options hash (see below) 	|

**Options**

| Key    				 | Type     | Defaults	| Notes	|
| ---------------------- | ----------- | -------- | --------------|
| Version 			 | Integer     | 0 | Commit version of the network, or 0 to use the latest version.|
| Other Version	 	 | Integer     | 0 | Commit version of the other network, or 0 to use the latest version.|
| Scenario	      	 | String      | "Base"  | Scenario to compare, "Base" for the base scenario, or "" for all scenarios.  |
| Selection List ID	 | Integer	   | 0 | Selection list ID.  |
| Select Changed Objects| Boolean  | false   |            |
| Ignore Flags	      	| Boolean  | false   |            |
| Ignore Defaults	 	| Boolean  | false   |            |
| Ignore Unique IDs     | Boolean  | false   |            |
| Use Display Precision	| Boolean  | true  	 |		      |
| Output Format		    | String   | "CSV"   | "CSV", "HTML", or "TEXT"    |

{::/WSPRO}

{::WSPRO}

## compare_scenarios

```ruby
#compare_scenarios(scenario_A, scenario_B, file_name, options) ⇒ void
```

`EXCHANGE`, `UI`

Compares two scenarios and outputs the result to a file.

```ruby
net = WSApplication.current_network
file_name = "C:/temp/compare.txt"
options = {
  "Output Format" => "TEXT"
}
net.compare_scenarios("Base","A", file_name, options)
WSApplication.open_text_view('Compare', file_name, false)
```

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| scenario_A   | String	 | The first scenario for comparison.  |
| scenario_B   | String  | The second scenario for comparison. |
| file_name    | String	 | Output file. 	|
| options      | Hash	 | Options hash (see below). 	|

**Options**

| Key    				 | Type     | Defaults	| Notes	|
| ---------------------- | ----------- | -------- | --------------|
| Output Format		    | String   | "TEXT"   | "HTML", or "TEXT"    |

{::/WSPRO}

{::WSPRO}

## control

```ruby
#control ⇒ WSOpenNetwork
```

`UI`

This method can only be called from the UI on a WS Pro network object (not a control). 
It returns another WSOpenNetwork object which is the control. It returns nil if there is no control open in the network.

**Example**

```ruby
net=WSApplication.current_network
control = net.control
puts control.current_scenario
net.current_scenario = '1'
control.current_scenario = '1'

control.row_objects('wn_ctl_node').each do |ro|
	puts ro.id
end
```

{::/WSPRO}



{::WSPRO}

## create_ldf_live_data_point

```ruby
#create_ldf_live_data_point(name, effective_channel_type) ⇒ void
```

`EXCHANGE`, `UI`

Creates a live data point from a live data feed.

**Parameters**

| Name     | Type(s)     | Description	|
| -------- | ----------- | --------------|
| name   | String	 | Name of the live data feed  |
| effective_channel_type	   | String  | Effective channel type (options are: '', 'DUAL', 'PRESSURE', 'FLOW', 'CONCENTRATION', 'PUMP', 'OPENING', 'NUMBER', 'PC_VOLUME'). |

{::/WSPRO}

## csv_export

```ruby
#csv_export(filename, options) ⇒ void
```

`EXCHANGE`, `UI`

Exports data to CSV.

See `WSBaseNetworkObject.csv_export`.

## csv_import

```ruby
#csv_import(filename, options) ⇒ void
```

`EXCHANGE`, `UI`

Imports data from CSV.

See `WSBaseNetworkObject.csv_import`.

## current_scenario

```ruby
#current_scenario ⇒ String
```

`EXCHANGE`, `UI`

Returns the current scenario of the network. If the current scenario is the base scenario, returns the string `Base` (in English).

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## current_scenario= (Set)

```ruby
#current_scenario=(name) ⇒ void
```

`EXCHANGE`, `UI`

Sets the current scenario of the network. The scenario must exist.

**Parameters**

| Name | Type(s)     | Description                                                                     |
| ---- | ----------- | ------------------------------------------------------------------------------- |
| name | String, nil | The name of the scenario, if nil then the scenario is set to the base scenario. |

## current_timestep

```ruby
#current_timestep ⇒ Integer
```

`EXCHANGE`, `UI`

The WSOpenNetwork object has a current timestep corresponding to the current timestep results have when opened in the software's UI. It determines the timestep for which the 'result' method of the WSRowObject returns its value. This method returns the index of the current timestep, with the first timestep being index 0 and the final timestep begin timestep_count - 1. The value of -1, representing the 'maximum' 'timestep' is also possible. The initial value when a sim is opened in ICM Exchange will be 0 if there are time varying results, otherwise -1 for the 'maximum' 'timestep'.

```ruby
puts network.current_timestep_time
=> 0
```

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

## current_timestep= (Set)

```ruby
#current_timestep=(index) ⇒ void
```

`EXCHANGE`

Sets the current network timestep.

**Parameters**

| Name  | Type(s) | Description                                                                                             |
| ----- | ------- | ------------------------------------------------------------------------------------------------------- |
| index | Integer | The timestep index, 0 sets the current timestep to the first timestep, -1 returns the maximum timestep. |

## current_timestep_time

```ruby
#current_timestep_time ⇒ DateTime
```

`EXCHANGE`, `UI`

Returns the actual time of the current timestep.

```ruby
puts network.current_timestep_time
=> ?
```

**Parameters**

| Name   | Type(s)  | Description |
| ------ | -------- | ----------- |
| Return | DateTime |             |

## delete_scenario

```ruby
#delete_scenario(name) ⇒ void
```

`EXCHANGE`, `UI`

Deletes a named scenario from the network. If the deleted scenario is the current scenario, the network will switch to the base scenario.

```ruby
puts network.current_scenario
=> 'ScenarioBadger'

network.delete_scenario('ScenarioBadger')

puts network.current_scenario
=> 'Base'
```

**Parameters**

| Name | Type(s) | Description                         |
| ---- | ------- | ----------------------------------- |
| name | String  | The name of the scenario to delete. |

## delete_selection

```ruby
#delete_selection ⇒ void
```

`EXCHANGE`, `UI`

Deletes the currently selected objects from the network, in the current scenario.

{::WSPRO}

## delete_superfluous_dummy_nodes

```ruby
#delete_superfluous_dummy_nodes(tables, field) ⇒ void
```

`EXCHANGE`, `UI`

Deletes all objects in node tables where the named field (`field` parameter) is set to Y, and the object is not the upstream or downstream node in one of the tables in the array.

This method is used in conjunction with the open data import centre, where dummy nodes have been added at the ends of links (e.g. because they have been imported from a GIS where they are represented as point objects) but the links have since been deleted.

**Parameters**

| Name   | Type(s)       | Description                                        |
| ------ | ------------- | -------------------------------------------------- |
| tables | Array\<String> | Table names of link objects e.g. `wn_pst`.         |
| field  | String        | Name of a text (string) field, e.g. `user_text_1`. |

{::/WSPRO}

{::ICM}

## download_mesh_job_log

```ruby
#download_mesh_job_log(job_id, path) ⇒ void
```

`EXCHANGE`

Copies the log output from a [#mesh_async](#mesh_async) job to a new file.

**Parameters**

| Name   | Type(s) | Description                                            |
| ------ | ------- | ------------------------------------------------------ |
| job_id | Integer | The job id from the [#mesh_async](#mesh_async) method. |
| path   | String  | Path to the new file, including extension (`.txt`).    |

{::/ICM}

{::WSPRO}

## duplicate_scenario_into_network

```ruby
#duplicate_scenario_into_network(scenario, network) ⇒ void
```

`EXCHANGE`, `UI`

Duplicates a scenario from a network or control to the base scenario in another empty network or control.

```ruby
iwdb = WSApplication.current_database
net = WSApplication.current_network
new_network = iwdb.model_object_from_type_and_id('Geometry',5034)
net.duplicate_scenario_into_network('A',new_network)
    
control = net.control
new_control = iwdb.model_object_from_type_and_id('Control',5035)
control.duplicate_scenario_into_network('A',new_control)
```

**Parameters**

| Name   | Type(s)       | Description                                        |
| ------ | ------------- | -------------------------------------------------- |
| scenario | String | The name of the scenario.        |
| network  | WSNumbatNetworkObject	| The empty network or control to copy the scenario into. |

{::/WSPRO}

## each

```ruby
#each { |ro| ... } ⇒ WSRowObject
```

`EXCHANGE`, `UI`

Iterates through each object in the network.

**Parameters**

| Name   | Type(s)     | Description |
| ------ | ----------- | ----------- |
| Return | WSRowObject |             |

## each_selected

```ruby
#each_selected { |ro| ... } ⇒ WSRowObject
```

`EXCHANGE`, `UI`

Iterates through each selected object in the network.

**Parameters**

| Name   | Type(s)     | Description |
| ------ | ----------- | ----------- |
| Return | WSRowObject |             |

{::WSPRO}

## expand_short_links

```ruby
#expand_short_links(options) ⇒ void
```

`EXCHANGE`, `UI`

Expands the selected links, similar to the user interface 'Expand Short Links' tool. This is used to visually expand generated link objects like valves, meters, or pumping stations.

The links must be selected, **and** their table type should be included in the `Tables` array of the options hash.

The options hash must exist, and has the following keys:

| Key                       |     Type      | Default | Description                                                             |
| ------------------------- | :-----------: | :-----: | ----------------------------------------------------------------------- |
| Expansion threshold       |     Float     |    1    | Uses user length units or native units (m) depending on global settings |
| Minimum resultant length  |     Float     |    1    | Uses user length units or native units (m) depending on global settings |
| Flag                      |    String     |   nil   |                                                                         |
| Protect connection points |    Boolean    |  false  |                                                                         |
| Recalculate length        |    Boolean    |  false  |                                                                         |
| Use user flag             |    Boolean    |  false  |                                                                         |
| Tables                    | Array\<String> |   []    | Array of internal table names, e.g. `wn_valve`, `wn_meter`, `wn_pst`    |

**Parameters**

| Name    | Type(s) | Description      |
| ------- | ------- | ---------------- |
| options | Hash    | See description. |

{::/WSPRO}

## export_ids

```ruby
#export_ids(filename, options) ⇒ void
```

`EXCHANGE`, `UI`

Exports the IDs of WSRowObjects to a file, grouped by table.

The options hash has the following keys:

| Key            | Type    | Default | Description                                                                      |
| -------------- | ------- | ------- | -------------------------------------------------------------------------------- |
| Selection Only | Boolean | false   | If true, only the currently selected WSRowObjects will be exported               |
| UTF8           | Boolean | false   | If true will save the file with UTF8 encoding, otherwise will use current locale |

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name     | Type(s)   | Description                                     |
| -------- | --------- | ----------------------------------------------- |
| filename | String    | Path to the file, including extension (`.txt`). |
| options  | Hash, nil | See description.                                |

## field_names

```ruby
#field_names(table) ⇒ Array<String>
```

`EXCHANGE`, `UI`

Returns the field names for a given table.

```ruby
network.field_names('wn_node').each { |s| puts s }
```

**Parameters**

| Name   | Type(s)       | Description                                  |
| ------ | ------------- | -------------------------------------------- |
| table  | String        | The name of the table (type) of wsrowobject. |
| Return | Array\<String> |                                              |

{::ICM}

## gauge_timestep_count

```ruby
#gauge_timestep_count ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of gauge timesteps.

**Parameters**

| Name   | Type(s) | Description                                                                                                                                        |
| ------ | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Return | Integer | The number of gauge timesteps, if there are no gauge timesteps (e.g. no objects are gauged, or the gauge timestep multiplier is 0) this will be 0. |

{::/ICM}

{::ICM}

## gauge_timestep_time

```ruby
#gauge_timestep_time(index) ⇒ DateTime
```

`EXCHANGE`, `UI`

Returns the actual time of the timestep.

```ruby
puts network.gauge_timestep_time(0)
=> ?
```

**Parameters**

| Name   | Type(s)  | Description               |
| ------ | -------- | ------------------------- |
| index  | Integer  | The gauge timestep index. |
| Return | DateTime |                           |

{::/ICM}

{::WSPRO}

## get_demand_categories

```ruby
#get_demand_categories ⇒ Array<String>
```

`EXCHANGE`, `UI`

Returns all demand categories referenced in this network.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | Array\<String> |             |

{::/WSPRO}

## gis_export

```ruby
#gis_export(format, options, location) ⇒ void
```

`EXCHANGE`, `UI`

Exports the network data to GIS format. See the [WSNumbatNetworkObject.gis_export](./wsnumbatnetworkobject.md) method.

Note: This method previously included capitalization, we recommend using the new lower case method name.

{::WSPRO}

## infer_network_values

```ruby
#infer_network_values(inference, ground_model) ⇒ void
```

`EXCHANGE`, `UI`

Runs an inference object on the network.

**Parameters**

| Name         | Type(s)                             | Description                                                                                           |
| ------------ | ----------------------------------- | ----------------------------------------------------------------------------------------------------- |
| inference    | Integer, String, WSModelObject      | The inference object - can be the id, scripting path, or a wsmodelobject of the correct type.         |
| ground_model | Integer, String, WSModelObject, nil | Optional ground model to use - can be the id, scripting path, or a wsmodelobject of the correct type. |

{::/WSPRO}

{::ICM}

## infodrainage_import

```ruby
#infodrainage_import(filename, log) ⇒ void
```

`EXCHANGE`

Imports an InfoDrainage model into the network.

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name     | Type(s) | Description                                                                                    |
| -------- | ------- | ---------------------------------------------------------------------------------------------- |
| filename | String  | Filepath to the infodrainage file including extension `.iddx`.                                 |
| log      | String  | Filepath to save the import log including extension `.txt`, which will be in rich text format. |

{::/ICM}

{::WSPRO}

## isolation_trace 

```ruby
#isolation_trace(selection_to_be_isolated, close_downstream, assume_valve_at_meter, selection_ignore_valves, selection_closed_links, selection_isolated, selection_customer_points, selection_spatial_data, report) ⇒ Boolean
```

`EXCHANGE`

Performs an isolation trace on the network.

**Parameters**

| Name   					| Type(s)        		| Description |
| ------------------------- | --------------------- | ------------------------------------------------------------- |
| selection_to_be_isolated  | WSNetSelectionList 	| Selection of links to be isolated.            				|
| close_downstream   		| Boolean 				| Close downstream valves.            							|
| assume_valve_at_meter   	| Boolean 				| Close at meter.            									|
| selection_ignore_valves   | WSNetSelectionList 	| Valves to ignore.            									|
| selection_closed_links   	| WSNetSelectionList 	| Selection list to update with closed links.           		|
| selection_isolated  		| WSNetSelectionList 	| Selection list of isolated objects.            				|
| selection_customer_points | WSNetSelectionList 	| Selection list to update with customer points isolated.       |
| selection_spatial_data   	| WSNetSelectionList 	| Selection list to update with spatial data points isolated.	|
| report   					| String 				| Path to write the HTML report.            					|
| Return				   	| Boolean 				| 					          									|

## isolation_trace_ex

```ruby
#isolation_trace_ex(selection_to_be_isolated, close_downstream, assume_valve_at_meter, selection_ignore_valves, selection_closed_links, selection_isolated, selection_customer_points, selection_spatial_data, report, close_at) ⇒ Boolean
```

`EXCHANGE`

Performs an isolation trace on the network. This method has an extra close_at parameter.

**Parameters**

| Name   					| Type(s)        		| Description |
| ------------------------- | --------------------- | ------------------------------------------------------------- |
| selection_to_be_isolated  | WSNetSelectionList 	| Selection of links to be isolated.            				|
| close_downstream   		| Boolean 				| Close downstream valves.            							|
| assume_valve_at_meter   	| Boolean 				| Close at meter.            									|
| selection_ignore_valves   | WSNetSelectionList 	| Valves to ignore.            									|
| selection_closed_links   	| WSNetSelectionList 	| Selection list to update with closed links.           		|
| selection_isolated  		| WSNetSelectionList 	| Selection list of isolated objects.            				|
| selection_customer_points | WSNetSelectionList 	| Selection list to update with customer points isolated.       |
| selection_spatial_data   	| WSNetSelectionList 	| Selection list to update with spatial data points isolated.	|
| report   					| String 				| Path to write the HTML report.            					|
| Return				   	| Boolean 				| 					          									|

close_at [Hash] close options:

**Hash values**

| Hash value   		| Type(s)       | Default 	|
| -----------------	| ------------- | --------- |
| Transfer Nodes 	| Boolean 		| True 		|
| Fixed Head Nodes 	| Boolean 		| True 		|
| Well Nodes 		| Boolean 		| True 		|
| Area Change 		| Boolean 		| True 		|
| Reservoir Nodes 	| Boolean 		| True 		|

**To ignore area changes**

```ruby
close_at = { "Area Change" => false}
```
{::/WSPRO}

{::ICM}

## list_gauge_timesteps

```ruby
#list_gauge_timesteps ⇒ Array<DateTime>
```

`EXCHANGE`, `UI`

Returns the times of all gauge timesteps, in order.

**Parameters**

| Name   | Type(s)         | Description |
| ------ | --------------- | ----------- |
| Return | Array\<DateTime> |             |

{::/ICM}

## list_gis_export_tables

```ruby
#list_gis_export_tables ⇒ Array<String>
```

`EXCHANGE`, `UI`

Returns the tables that can be exported using the [#gis_export](#gis_export) method.

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | Array\<String> |             |

## list_timesteps

```ruby
#list_timesteps ⇒ Array<DateTime>
```

`EXCHANGE`, `UI`

Returns the times of all timesteps, in order.

**Parameters**

| Name   | Type(s)         | Description |
| ------ | --------------- | ----------- |
| Return | Array\<DateTime> |             |

{::ICM}

## load_mesh_job

```ruby
#load_mesh_job(job_id) ⇒ void
```

`EXCHANGE`

Loads the the completed mesh from a [#mesh_async](#mesh_async) job into the network.

**Parameters**

| Name   | Type(s) | Description                                            |
| ------ | ------- | ------------------------------------------------------ |
| job_id | Integer | The job id from the [#mesh_async](#mesh_async) method. |

{::/ICM}

## load_selection

```ruby
#load_selection(selection_list) ⇒ void
```

`EXCHANGE`, `UI`

Selects objects in the network from the selection list object.

**Parameters**

| Name           | Type(s)                        | Description                                                                                 |
| -------------- | ------------------------------ | ------------------------------------------------------------------------------------------- |
| selection_list | Integer, String, WSModelObject | The selection list - can be the id, scripting path, or a wsmodelobject of the correct type. |

{::ICM}

## mesh

```ruby
#mesh(options) ⇒ Hash<String, Boolean>
```

`EXCHANGE`

Meshes one or more 2D zones. This method performs meshing synchronously i.e. it blocks the script thread. To perform meshing asynchronously, see the [#mesh_async](#mesh_async) method.

The options hash contains the following keys:

| Name                     |              Type              | Required | Description                                                                                                                                                                                                                                                                                      |
| ------------------------ | :----------------------------: | :------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| GroundModel              | Integer, String, WSModelObject |   Yes    | This may either be the scripting path, the ID, or the WSModelObject representing a ground model (either grid or TIN). If the ID is negative then it represents a TIN ground model i.e. -7 represents the TIN ground model with ID 7. If the ID is positive it represents a gridded ground model. |
| VoidsFile                |             String             |    No    | The path of a GIS file containing the voids                                                                                                                                                                                                                                                      |
| VoidsFeatureClass        |             String             |    No    | For a GeoDatabase, the feature class within the GeoDatabase for the voids                                                                                                                                                                                                                        |
| VoidsCategory            |             String             |    No    | The category of polygon within the network used for voids                                                                                                                                                                                                                                        |
| BreakLinesFile           |             String             |    No    | The path of a GIS file containing the break lines                                                                                                                                                                                                                                                |
| BreakLinesFeatureClass   |             String             |    No    | For a GeoDatabase, the feature class within the GeoDatabase for the break lines                                                                                                                                                                                                                  |
| BreakLinesCategory       |             String             |    No    | The category of polyline within the network used for break lines                                                                                                                                                                                                                                 |
| WallsFile                |             String             |    No    | The path of a GIS file containing the walls                                                                                                                                                                                                                                                      |
| WallsFeatureClass        |             String             |    No    | For a GeoDatabase, the feature class within the GeoDatabase for the walls                                                                                                                                                                                                                        |
| WallsCategory            |             String             |    No    | The category of polyline within the network used for walls                                                                                                                                                                                                                                       |
| 2DZones                  |     String, Array\<String>      |   Yes    | If the 2DZonesSelectionList parameter is absent and this parameter is absent or nil all 2D zones will be meshed. Otherwise can contain the name of a 2D zone as a string, or an array of strings containing the names of 2D zones                                                                |
| 2DZonesSelectionList     | Integer, String, WSModelObject |    No    | A selection list of 2D zones to mesh                                                                                                                                                                                                                                                             |
| LowerElementGroundLevels |            Boolean             |    No    | If present and evaluates to true, the process will lower 2D mesh elements with ground levels higher than the adjacent bank levels                                                                                                                                                                |
| RunOn                    |             String             |    No    | The computer to run the job on - `.` for 'this computer', `*` for 'any computer'                                                                                                                                                                                                                 |
| LogFile                  |             String             |    No    | The path of the log file with `.HTML` extension, if empty one will not be saved. This can only be used if only one 2D zone is meshed.                                                                                                                                                            |
| LogPath                  |             String             |    No    | The path of a folder for the log files. This may be used however many 2D zones are meshed. The file will be given the name of the 2D zone with the file type HTML.                                                                                                                               |

- For the pairs of keys (voids, break lines and wall) only one of the two values may be set.
- If any of the VoidsFile, WallsFile or BreakLinesFile values are set, i.e. if any voids, walls or break lines are to be read in from a GIS files, the GIS component must be set with `WSApplication.map_component=` The user must have the GIS component they are selecting.
- The FeatureClass keys can only be set if the corresponding File key is set and the map control is set and is not MapXTreme.
- Only one of the 2DZones and 2DZonesSelectionList keys may be present.
- Only one of the LogFile and LogDir keys may be present.

**Parameters**

| Name    | Type(s)               | Description                                                                          |
| ------- | --------------------- | ------------------------------------------------------------------------------------ |
| options | Hash                  | An options hash, see method description.                                             |
| Return  | Hash<String, Boolean> | A hash with the 2d zone names as keys, with a boolean indicating success or failure. |

{::/ICM}

{::ICM}

## mesh_async

```ruby
#mesh_async(options) ⇒ Array<Integer>
```

`EXCHANGE`

Meshes one or more 2D zones. Similar to the `#mesh` method, except it runs asynchronously i.e. it does not block the script thread.

Each 2D zone will have a unique job ID, returned in the array. These are integers that can be used in the `#load_mesh_job`, `#cancel_mesh_job`, `#download_mesh_job_log`, and `#mesh_job_status` methods of this network class, or the [WSApplication.wait_for_jobs](wsapplication.md) method.

**Parameters**

| Name    | Type(s)        | Description                                                                                          |
| ------- | -------------- | ---------------------------------------------------------------------------------------------------- |
| options | Hash           | An options hash, identical to [#mesh](#mesh) except it does not have the `logfile` or `logdir` keys. |
| Return  | Array\<Integer> | An array of job ids, which can be used in other methods (see description).                           |

{::/ICM}

{::ICM}

## mesh_job_status

```ruby
#mesh_job_status(job_id) ⇒ String
```

`EXCHANGE`

Returns the current status of a mesh job, identified by a job ID from [#mesh_async](#mesh_async).

**Parameters**

| Name   | Type(s) | Description                                            |
| ------ | ------- | ------------------------------------------------------ |
| job_id | Integer | The job id from the [#mesh_async](#mesh_async) method. |
| Return | String  |                                                        |

{::/ICM}

## model_object

```ruby
#model_object ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Returns a `WSModelObject` (or derived class) associated with this network.

If the network was loaded from a sim, then the model object of that sim will be returned. This is different from `#network_model_object` which always returns the network.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | WSModelObject |             |

{::ICM}

## mscc_export_cctv_surveys

```ruby
#mscc_export_cctv_surveys(export_file, export_images, selection_only, log_file ⇒ Boolean
```

`EXCHANGE`, `UI`

This method exports CCTV survey data from a Collection Network to the MSCC4 XML format.

The export_file argument specified the output XML file and log_file the location of a text file for errors.

The other two arguments take Boolean values. export_images controls whether defect images are to be exported and selection_only will limit the export to selected objects.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Boolean |             |

{::/ICM}

{::ICM}

## mscc_export_manhole_surveys

```ruby
#mscc_export_manhole_surveys(export_file, export_images, selection_only, log_file) ⇒ Boolean
```

`EXCHANGE`, `UI`

This method exports manhole survey data from a Collection Network to the MSCC5 XML format.

The export_file argument specified the output XML file and log_file the location of a text file for errors.

The other two arguments take Boolean values. export_images controls whether defect images are to be exported and selection_only will limit the export to selected objects.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Boolean |             |

{::/ICM}

{::ICM}

## mscc_import_cctv_surveys

```ruby
#mscc_import_cctv_surveys(import_file, import_flag, import_images, id_gen, overwrite, log_file)
```

`EXCHANGE`, `UI`

This method imports CCTV survey data into a Collection Network from the MSCC4 XML format.

The import_file argument specifies the XML file and log_file the location of a text file for errors.

The import_flag text specifies the data flag for imported fields. import_images controls whether defect images are to be imported.

To prevent the overwriting of existing surveys in the event of name clashes, set overwite to false.

The id generation parameter, id_gen, uses the following values (these correspond to the user interface options in the help):

- 1 - StartNodeRef, Direction, Date and Time
- 2 - StartNodeRef, Direction and an index for uniqueness
- 3 - US node ID, Direction, Date and Time
- 4 - US node ID, Direction and an index for uniqueness
- 5 - ClientDefined1
- 6 - ClientDefined2
- 7 - ClientDefined3

{::/ICM}

{::ICM}

## mscc_import_manhole_surveys

```ruby
#mscc_import_manhole_surveys(import_file, import_flag, import_images, id_gen, overwrite, log_file)
```

`EXCHANGE`, `UI`

This method imports manhole survey data into a Collection Network from the MSCC5 XML format.

The import_file argument specifies the XML file and log_file the location of a text file for errors.

The import_flag text specifies the data flag for imported fields. import_images controls whether defect images are to be imported.

To prevent the overwriting of existing surveys in the event of name clashes, set overwite to false.

The id generation parameter, id_gen, uses the following values (these correspond to the user interface options in the help):

- 1 - Manhole/Node reference, Date and Time
- 2 - Manhole/Node reference and an index for uniqueness

{::/ICM}

## network_model_object

```ruby
#network_model_object ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Returns the `WSModelObject` (or derived class) associated with this network.

If the network was loaded from a sim, then the model object of that network will be returned. This is different from `#model_object` which would return the sim.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | WSModelObject |             |

## new_row_object

```ruby
#new_row_object(type) ⇒ WSRowObject
```

`EXCHANGE`, `UI`

Creates a new object in this network. This must be done within a network transaction, and you must set a primary ID for the object before you can write changes to it.

**Parameters**

| Name   | Type(s)     | Description      |
| ------ | ----------- | ---------------- |
| type   | String      | The object type. |
| Return | WSRowObject |                  |

## objects_in_polygon

```ruby
#objects_in_polygon(polygon, type) ⇒ Array<WSRowObject>
```

`EXCHANGE`, `UI`

Returns an array of the `WSRowObject` objects inside the `polygon` geometry, matching the `type` parameter.

When using an array of strings as the `type`, all values must be unique (no duplicates) and cannot contain a category and a table within the same category.

**Parameters**

| Name    | Type(s)                    | Description                                                              |
| ------- | -------------------------- | ------------------------------------------------------------------------ |
| polygon | WSRowObject                | An object containing polygon geometry.                                   |
| type    | String, Array\<String>, nil | The name(s) of a type or category of object, nil will search all tables. |
| Return  | Array\<WSRowObject>         |                                                                          |

## odec_export_ex

```ruby
#odec_export_ex(format, config, options, table, *args) ⇒ void
```

`EXCHANGE`, `UI`

Exports network data using the Open Data Export Centre.

See [WSBaseNetworkObject.odec_export_ex](wsbasenetworkobject.md).

## odic_import_ex

```ruby
#odic_import_ex(format, config, options, table, *args) ⇒ Array<WSRowObject>
```

`EXCHANGE`, `UI`

Imports and updates network data using the Open Data Import Centre, returning an array of the objects created or updated in the process. Objects may also be deleted, but these are not returned / listed.

See [WSBaseNetworkObject.odec_import_ex](wsbasenetworkobject.md).

**Parameters**

| Name   | Type(s)            | Description |
| ------ | ------------------ | ----------- |
| Return | Array\<WSRowObject> |             |

{::WSPRO}

## rename_nodes

```ruby
#rename_nodes(control, options) ⇒ void
```

`EXCHANGE`, `UI`

Renames all existing nodes in the network. See also `#set_node_namer` method.

The options hash has the following keys:

- 'Method' (String) : one of `UK`, `IRELAND`, `XY8`, `XY10`, `XY12`, `XY14`, or `CUSTOM`
- 'Custom Pattern' (String) : if Method is 'CUSTOM', this is the custom string format, leave unset otherwise

**Parameters**

| Name    | Type(s)       | Description                                                                                       |
| ------- | ------------- | ------------------------------------------------------------------------------------------------- |
| control | WSOpenNetwork | The control network, this is loaded so that any node name changes are reflected in linked fields. |
| options | Hash          | A hash of options, see method description.                                                        |

{::/WSPRO}

{::WSPRO}

## reintegrate_scenario

```ruby
#reintegrate_scenario(name) ⇒ void
```

`EXCHANGE`, `UI`

Reintegrates a scenario into the base.

```ruby
net = WSApplication.current_network
net.reintegrate_scenario('A')
```

**Parameters**

| Name   | Type(s)          | Description                     |
| ------ | ---------------- | --------------------------------|
| name   | String           | The name of the scenario.        |

{::/WSPRO}

{::ICM}

## ribx_export_surveys

```ruby
#ribx_export_surveys(export_file, selection_only, log_file) ⇒ Boolean
```

`EXCHANGE`, `UI`

Exports manhole survey and cctv survey data from a Collection Network to the RIBX XML format.

The export_file argument specified the output XML file and log_file the location of a text file for errors.

The selection_only argument is a Boolean value and will limit the export to selected objects if it is true.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Boolean |             |

{::/ICM}

{::ICM}

## ribx_import_surveys

```ruby
#ribx_import_surveys(import_file, import_flag, id_gen, overwrite, log_file)
```

`EXCHANGE`, `UI`

This method imports CCTV survey & manhole survey data into a Collection Network from the RIBX XML format.

The import_file argument specifies the XML file and log_file the location of a text file for errors.

The import_flag text specifies the data flag for imported fields.

To prevent the overwriting of existing surveys in the event of name clashes, set overwite to false.

The id generation parameter, id_gen, uses the following values (these correspond to the user interface options in the help).

- 1 - StartNodeRef, Direction, Date and Time
- 2 - StartNodeRef, Direction and an index for uniqueness
- 3 - US node ID, Direction, Date and Time
- 4 - US node ID, Direction and an index for uniqueness

{::/ICM}

## row_object

```ruby
#row_object(type, id) ⇒ WSRowObject?
```

`EXCHANGE`, `UI`

Returns a specific row object by type and ID.

```ruby
node = network.row_object('wn_node', 'ST543643')
raise "Could not get node" if node.nil?
```

**Parameters**

| Name   | Type(s)          | Description                                                         |
| ------ | ---------------- | ------------------------------------------------------------------- |
| type   | String           | The object type.                                                    |
| id     | String           | The object id, e.g. 'st543643' or `st543643.st543473.1`.            |
| Return | WSRowObject, nil | The object found, or nil if there is no such object in the network. |

## row_object_collection

```ruby
#row_object_collection(type) ⇒ WSRowObjectCollection
```

`EXCHANGE`, `UI`

Returns all row objects of a given type as a `WSRowObjectCollection`.

**Parameters**

| Name   | Type(s)               | Description                                                                            |
| ------ | --------------------- | -------------------------------------------------------------------------------------- |
| type   | String                | The object type.                                                                       |
| Return | WSRowObjectCollection | All objects of this type in the network, will be empty if there are none of this type. |

## row_object_collection_selection

```ruby
#row_object_collection_selection(type) ⇒ WSRowObjectCollection
```

`EXCHANGE`, `UI`

Returns all selected row objects of a given type as a `WSRowObjectCollection`.

**Parameters**

| Name   | Type(s)               | Description                                                                                              |
| ------ | --------------------- | -------------------------------------------------------------------------------------------------------- |
| type   | String                | The object type.                                                                                         |
| Return | WSRowObjectCollection | The selected objects of this type in the network, will be empty if there are none of this type selected. |

## row_objects

```ruby
#row_objects(type) ⇒ Array<WSRowObject>
```

`EXCHANGE`, `UI`

Returns all row objects of a given type in an Array.

**Parameters**

| Name   | Type(s)            | Description                                                               |
| ------ | ------------------ | ------------------------------------------------------------------------- |
| type   | String             | The object type.                                                          |
| Return | Array\<WSRowObject> | The objects of this type in the network, will be empty if there are none. |

## row_objects_from_asset_id

```ruby
#row_objects_from_asset_id(type, id) ⇒ Array<WSRowObject>
```

`EXCHANGE`, `UI`

Returns all row objects of a given type with this Asset ID. This method is useful when working with imported link objects, where you may not know the multi-part ID.

Asset ID's are not guaranteed to be unique, so there may be multiple results. You can use the `first` Array method to access the first object.

```ruby
nodes = network.row_objects_from_asset_id('wn_node', 'ST543643')
puts nodes.first['asset_id']
=> 'ST543643'
```

You can also create your own method which enforces a single result, returning nil if no object is found or multiple objects are found:

```ruby
def unique_row_object_from_asset_id(network, type, id)
  nodes = network.row_objects_from_asset_id(type, id)
  return (nodes.size != 1) ? nil : nodes.first
end
```

**Parameters**

| Name   | Type(s)            | Description                                                                 |
| ------ | ------------------ | --------------------------------------------------------------------------- |
| type   | String             | The object type - cannot be `_nodes` or `_links`.                           |
| id     | String             | The object's asset id e.g. 'st543643'.                                      |
| Return | Array\<WSRowObject> | The objects found in the network, will be an empty array if there are none. |

## row_objects_selection

```ruby
#row_objects_selection(type) ⇒ Array<WSRowObject>
```

`EXCHANGE`, `UI`

Returns all selected row objects of a given type in an Array.

**Parameters**

| Name   | Type(s)            | Description                                                                                              |
| ------ | ------------------ | -------------------------------------------------------------------------------------------------------- |
| type   | String             | The object type.                                                                                         |
| Return | Array\<WSRowObject> | The selected objects of this type in the network, will be empty if there are none of this type selected. |

## run_sql

```ruby
#run_sql(table, query) ⇒ void
```

`EXCHANGE`, `UI`

Runs a SQL query on this network.

The SQL query can include multiple clauses, including saving results to a file, but cannot use any of the options that open results or prompt grids.

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name  | Type(s) | Description                                                                                |
| ----- | ------- | ------------------------------------------------------------------------------------------ |
| table | String  | The table name, `_nodes` or `_links` are equivalent to 'all nodes' and 'all links' in sql. |
| query | String  | The sql query.                                                                             |

{::ICM}

## run_inference

```ruby
#run_inference(inference, ground_model, mode, zone, error_file) ⇒ void
```

`EXCHANGE`, `UI`

Runs the inference object on this network, which must be a collection asset network or a distribution asset network.

The supported modes are:

- nil, false or the string `Network` - run the inference on the whole network
- true or the string `Selection` - run the inference on the current selection (which, of course, must be set up within the script)
- the string `Zone` - run the inference for the zone specified in the following parameter.
- The string `Category` - run the inference for zones with the zone specified in the following parameter.

The ground model parameter must be nil when this method is used from the UI. If there is a ground model loaded into the network (either TIN or grid), it will be used instead.

**Parameters**

| Name         | Type(s)                             | Description                                                                                                                                    |
| ------------ | ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| inference    | Integer, String, WSModelObject      | The inference object - can be the id, scripting path, or a wsmodelobject of the correct type.                                                  |
| ground_model | Integer, String, WSModelObject, nil | Optional ground model to use (exchange only) - can be the id (grid ground model only), scripting path, or a wsmodelobject of the correct type. |
| mode         | String, Boolean, nil                | See method description.                                                                                                                        |
| zone         | String, nil                         | If the mode parameter is `zone` or `category`, this string should be the name of the zone or zone category.                                    |
| error_file   | String, nil                         | Path to an error file.                                                                                                                         |

{::/ICM}

{::ICM}

## run_stored_query_object

```ruby
#run_stored_query_object(stored_query) ⇒ void
```

`EXCHANGE`, `UI`

Runs a stored query on this network.

**Parameters**

| Name         | Type(s)                        | Description                                                                                      |
| ------------ | ------------------------------ | ------------------------------------------------------------------------------------------------ |
| stored_query | Integer, String, WSModelObject | The stored query object - can be the id, scripting path, or a wsmodelobject of the correct type. |

{::/ICM}

## save_selection

```ruby
#save_selection(selection_list) ⇒ void
```

`EXCHANGE`, `UI`

Saves the current selection (in the current scenario) to an already existing selection list model object.

**Parameters**

| Name           | Type(s)                        | Description                                                                                        |
| -------------- | ------------------------------ | -------------------------------------------------------------------------------------------------- |
| selection_list | Integer, String, WSModelObject | The selection list object - can be the id, scripting path, or a wsmodelobject of the correct type. |

## scenarios

```ruby
#scenarios { |s| ... } ⇒ String
```

`EXCHANGE`, `UI`

Iterates through the scenarios, yielding a String of each scenario name. The base scenario is included as the string `Base` in English.

```ruby
  network.scenarios { |scenario| puts scenario }
```

```ruby
  network.scenarios do |scenario|
    puts scenario
  end
```

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## search_at_point

```ruby
#search_at_point(x, y, distance, types) ⇒ Array<WSRowObject>
```

`EXCHANGE`, `UI`

Find all objects within a distance of a given point.

When using an array of strings as the `type`, all values must be unique and cannot contain a category and a table within that category. This is similar to the `WSRowObject.objects_in_polygon` method.

**Parameters**

| Name     | Type(s)                    | Description                                                                      |
| -------- | -------------------------- | -------------------------------------------------------------------------------- |
| x        | Numeric                    | X coordinate.                                                                    |
| y        | Numeric                    | Y coordinate.                                                                    |
| distance | Numeric                    | Search radius around point.                                                      |
| type     | String, Array\<String>. nil | The name of a table or category, an array of names, or nil to search all tables. |
| Return   | Array\<WSRowObject>         |                                                                                  |

{::WSPRO}

## select_in_demand_area

```ruby
#select_in_demand_area(rowobject, open_control) ⇒ void
```

`EXCHANGE`, `UI`

Use existing WSOpenNetwork method [each_selected](#each_selected) to view selection.

Returns non zero if unable to select.

**Example**

```ruby
database = WSApplication.open

#need nw and ctl
geometry_id = 7
control_id = 3

#get the relevant network and control
network = database.model_object_from_type_and_id('geometry',geometry_id)
imoc = database.model_object_from_type_and_id('control',control_id)
clds = imoc.open()
nlds = network.open()

@ro
#show the demand areas
nlds.row_objects('wn_demand_area').each do |da|
	id = da['area_id']
	if(id=="35")
		@ro = da;
	end
	puts id
end

#pass a single row object or an array
nlds.select_in_demand_area(@ro,clds);
#nlds.select_in_demand_area(nlds.row_objects('wn_demand_area'))

#show selected items
nlds.each_selected() do |itm|
	puts itm.table() + ' ' + itm.id()
end

nlds.close()
clds.close()	
database.close()	
```

**Parameters**

| Name   | Type(s)     | Description                                                                                       |
| ------ | ----------- | ------------------------------------------------------------------------------------------------- |
| rowobject		| WSRowObject or Array<WSRowObject>       | The demand area(s) to be selected.    	 	|
| open_control  | WSOpenNetwork                           | The control associated with the network.    |

{::/WSPRO}

## selection_size

```ruby
#selection_size ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of objects currently selected.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

{::WSPRO}

## set_node_namer

```ruby
#set_node_namer(method, custom) ⇒ void
```

`EXCHANGE`, `UI`

Sets the auto-naming convention for new nodes.

**Parameters**

| Name   | Type(s)     | Description                                                                                       |
| ------ | ----------- | ------------------------------------------------------------------------------------------------- |
| method | String      | The renamer method, the options are: `uk`, `ireland`, `xy8`, `xy10`, `xy12`, `xy14`, `custom`.    |
| custom | String, nil | If `type` is `custom` then this is the custom format string, otherwise this should be set to nil. |

{::/WSPRO}

## set_projection_string

```ruby
#set_projection_string(string) ⇒ void
```

`EXCHANGE`

Sets the map projection string. The format of the string depends on the current map control.

Compatible projection strings or MapXTreme can be found in `C:\Program Files\Common Files\MapInfo\MapXtreme\VERSION\MapInfoCoordinateSystemSet.xml`, where VERSION will depend on the current application version.

E.g. for British National Grid [EPSG 27700]:

```xml
<gml:srsID>
  <gml:name gml:codeSpace="mapinfo">coordsys 8,79,7,-2,49,0.9996012717,400000,-100000</gml:name>
</gml:srsID>
```

The projection string is: `8,79,7,-2,49,0.9996012717,400000,-100000`.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| string | String  |             |

{::ICM}

## snapshot_export

```ruby
#snapshot_export(file) ⇒ void
```

`EXCHANGE`, `UI`

Exports a snapshot of the network to the given file. All objects are exported from all tables, but image files and GeoPlan properties and themes are not exported.

Snapshots cannot be exported from networks with uncommitted changes.

**Parameters**

| Name | Type(s) | Description       |
| ---- | ------- | ----------------- |
| file | String  | Path to the file. |

{::/ICM}

{::ICM}

## snapshot_export_ex

```ruby
#snapshot_export_ex(file, options) ⇒ void
```

`EXCHANGE`, `UI`

Exports a snapshot of the network to the given file. If no options hash is provided, all objects are exported from all tables, but image files and GeoPlan properties and themes are not exported.

Snapshots cannot be exported from networks with uncommitted changes.

The options hash contains the following keys:

| Name                              |     Type      | Description                                                                                                                                                                 |
| --------------------------------- | :-----------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SelectedOnly                      |    Boolean    | If present and true, only the currently selected objects are exported, otherwise by default all objects of the appropriate tables are exported.                             |
| IncludeImageFiles                 |    Boolean    | If present and true, includes the data for image files in the network, otherwise by default images are not exported.                                                        |
| IncludeGeoPlanPropertiesAndThemes |    Boolean    | If present and true, includes the data for GeoPlan properties and themes, otherwise by default they are not exported.                                                       |
| ChangesFromVersion                |    Integer    | If present, the snapshot will be of the different from the network's version with this commit ID, otherwise by default the current version of the network will be exported. |
| Tables                            | Array\<String> | If present, a list of the internal table names (as returned by the table_names method of this class) If not present then all tables will be exported.                       |

The SelectedOnlyOptions must not be mixed with the Tables option or the ChangesFromVersion option.

**Parameters**

| Name    | Type(s) | Description             |
| ------- | ------- | ----------------------- |
| file    | String  | Path to the file.       |
| options | Hash    | See method description. |

{::/ICM}

{::WSPRO}

## snapshot_import

```ruby
#snapshot_import(file) ⇒ void
```

`EXCHANGE`, `UI`

Imports a snapshot file into the network from a file.

**Parameters**

| Name | Type(s) | Description       |
| ---- | ------- | ----------------- |
| file | String  | Path to the file. |

{::/WSPRO}

{::ICM}

## snapshot_import_ex

```ruby
#snapshot_import_ex(file, options) ⇒ void
```

`EXCHANGE`, `UI`

Imports a snapshot file into the network from a file, with the provided options.

The options hash contains the following keys:

| Name                             |     Type      | Description                                                                                            |
| -------------------------------- | :-----------: | ------------------------------------------------------------------------------------------------------ |
| Tables                           | Array\<String> | A list of network table names to import. If this key is not provided then all tables will be imported. |
| AllowDeletes                     |    Boolean    |                                                                                                        |
| ImportGeoPlanPropertiesAndThemes |    Boolean    |                                                                                                        |
| UpdateExistingObjectsFoundByID   |    Boolean    |                                                                                                        |
| UpdateExistingObjectsFoundByUID  |    Boolean    |                                                                                                        |
| ImportImageFiles                 |    Boolean    |                                                                                                        |

**Parameters**

| Name    | Type(s) | Description             |
| ------- | ------- | ----------------------- |
| file    | String  | Path to the file.       |
| options | Hash    | See method description. |

{::/ICM}

{::ICM}

## snapshot_scan

```ruby
#snapshot_scan(file) ⇒ Hash<String, Any>
```

`EXCHANGE`, `UI`

Scans a snapshot file and returns a hash containing the following details:

- NetworkGUID (String) the GUID of the network from which the snapshot was exported.
- CommitGUID (String) the GUID of the commit of the network from which the snapshot was exported.
- CommitID (Integer) the ID of the commit of the network from which the snapshot was exported.
- NetworkTypeCode (String) the type of network from which the snapshot was exported. This matches the name of the network type e.g. 'Collection Network'
- DatabaseGUID (String) the GUID associated with the database version from which the snapshot was exported.
- DatabaseSubVersion (Integer) the 'subversion' associated with the database version from which the snapshot was exported.
- UnknownTableCount (Integer) the number of tables in the snapshot not recognised by the software, this will only be greater than 0 if the snapshot were exported from a more recent version of the software.
- FileCount (Integer) the number of image files contained within the snapshot.
- ContainsGeoPlanPropertiesAndThemes - Boolean - true if the snapshot was exported with the option to included GeoPlan properties and themes.
- Tables (Hash) a hash containing information about the tables exported:
  - ObjectCount (Integer) the number of objects in the snapshot for the table.
  - ObjectsWithOldVersionsCount (Integer)
  - ObjectsFoundByUID (Integer)
  - ObjectsFoundByID (Integer)
  - DeleteRecordsCount (Integer)
  - UnknownFieldCount (Integer) the number of unknown fields for the table, this will be zero unless the export is from a more recent version of the software than the user is using to import the data.

**Parameters**

| Name   | Type(s)           | Description                |
| ------ | ----------------- | -------------------------- |
| file   | String            | Path to the snapshot file. |
| Return | Hash<String, Any> |                            |

{::/ICM}

## table

```ruby
#table(name) ⇒ WSTableInfo
```

`EXCHANGE`, `UI`

Returns a `WSTableInfo` object for a specific table in this network.

**Parameters**

| Name   | Type(s)     | Description        |
| ------ | ----------- | ------------------ |
| name   | String      | Name of the table. |
| Return | WSTableInfo |                    |

## table_names

```ruby
#table_names ⇒ Array<String>
```

`EXCHANGE`, `UI`

Returns the names of all tables in this network.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | Array\<String> |             |

## tables

```ruby
#tables ⇒ Array<WSTableInfo>
```

`EXCHANGE`, `UI`

Returns an array of [WSTableInfo](wstableinfo.md) objects for the tables in this network.

**Parameters**

| Name   | Type(s)            | Description |
| ------ | ------------------ | ----------- |
| Return | Array\<WSTableInfo> |             |

## timestep_count

```ruby
#timestep_count ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of result timesteps, not including the maximum timestep.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

## timestep_time

```ruby
#timestep_time(timestep_no) ⇒ DateTime
```

`EXCHANGE`, `UI`

Returns the actual time of the timestep index provided.

**Parameters**

| Name        | Type(s)  | Description |
| ----------- | -------- | ----------- |
| timestep_no | Integer  |             |
| Return      | DateTime |             |

## transaction_begin

```ruby
#transaction_begin ⇒ void
```

`EXCHANGE`, `UI`

Begins a transaction, during which you can modify network data such as adding/removing objects or changing fields. Most changes to a network must be within a transaction.

A transaction can be ended with `#transaction_commit` (to save the changes) or `#transaction_rollback` (to abandon them).

## transaction_commit

```ruby
#transaction_commit ⇒ void
```

`EXCHANGE`, `UI`

Commits any changes to the network since `#transaction_begin`.

## transaction_rollback

```ruby
#transaction_rollback ⇒ void
```

`EXCHANGE`, `UI`

Rolls back (ends) the transaction, which reverts any changes made since `#transaction_begin`.

This should be used with caution if you are storing references to WSRowObjects or associated data, as this may break references and cause an exception when you attempt to access or work with them.

{::ICM}

## update_cctv_scores

```ruby
#update_cctv_scores ⇒ void
```

`EXCHANGE`, `UI`

Calculates CCTV scores for all surveys in the network using the current standard.

{::/ICM}

{::WSPRO}

## update_demand_area

```ruby
#update_demand_area(open_network, open_control, options) => WSValidations
```

`EXCHANGE`, `UI`

Equivalent of "Update demand area(s)" in the UI.

Returns validation result collection.

**Example**

```ruby
require 'date'

database = WSApplication.open

#get the relevant network and control
network = database.model_object_from_type_and_id('geometry',1081)
imoc = database.model_object_from_type_and_id('control',1082)
clds = imoc.open()
nlds = network.open()

#show the demand areas
nlds.row_objects('wn_demand_area').each do |da|
	id = da['area_id']
	puts id
end

begin
	nlds.transaction_begin()
	hashOptions = Hash.new
	hashOptions['demand_diagram'] = 1086
	hashOptions['live_data_config'] = 1083
	validation_results = nlds.update_demand_area(nlds.row_objects('wn_demand_area'),clds,hashOptions)
	nlds.transaction_commit()
	
	validation_results.each do |v|			
		puts "Type: #{v.type}\nCode: #{v.code}\nPriority: #{v.priority}\nObject type: #{v.object_type}\nObject id: #{v.object_id}\nField: #{v.field_description}\nMessage: #{v.message}\n\n"
	end
	
rescue => exception
	print("#{exception.message}")
	nlds.transaction_rollback
end

nlds.row_objects('wn_demand_area').each do |da|
	["area_id",
	"area_id_flag",
	"aznp",
	"aznp_flag",
	"aznp_node",
	"aznp_node_flag",
	"background_losses",
	"bounding_links",
	"bounding_links_flag",
	"bounding_links2",
	"calculated_spec_cons",
	"calibration_start",
	"calibration_start_flag",
	"demand_interpolation",
	"demand_interpolation_flag",
	"excess_unaccounted_for_water",
	"icf",
	"icf_flag",
	"ignore_leakage",
	"leakage_application",
	"leakage_application_flag",
	"leakage_profile",
	"leakage_profile_flag",
	"length_of_mains",
	"measurement_period",
	"measurement_period_flag",
	"minimum_night_flow",
	"multiplier",
	"multiplier_flag",
	"net_inflow",
	"number_unmetered_properties",
	"pcf",
	"pcf_flag",
	"pcf_method",
	"pcf_method_flag",
	"polygon_id",
	"polygon_id_flag",
	"total_inflows",
	"total_outflows",
	"unaccounted_for_water",
	"unmetered_demand",
	"unmetered_demand_flag",
	"unmetered_dom_nu",
	"unmetered_dom_nu_flag",
	"validation"].each do |field|
		puts "#{field}:#{da[field]}"
	end
	puts "\n"
end


nlds.close()
clds.close()	
database.close()	
```

**Parameters**

| Name   | Type(s)     | Description                                                                                       |
| ------ | ----------- | ------------------------------------------------------------------------------------------------- |
| open_network | WSOpenNetwork       | The network with the demand areas     |
| open_control | WSOpenNetwork       | The associated control			     |
| options      | Hash                | A hash containing the Demand Diagram ID and Live Data Config ID     |

{::/WSPRO}

{::WSPRO}

## update_demand_diagram_and_network

```ruby
#update_demand_diagram_and_network(demand_areas, open_control, options, optionsPropertyBased, optionsDirect)
```

`EXCHANGE`, `UI`

Equivalent of "Update demand diagram and network" in the UI.

Returns a hash of changes to network with a count of deleted, inserted, and modified objects, and the number of settings changed.

**Example**

```ruby
database = WSApplication.open

geometry_id = 7
control_id = 3
ddg_id = 16
ldc_id = 4

#get the relevant network and control
network = database.model_object_from_type_and_id('geometry',geometry_id)
imoc = database.model_object_from_type_and_id('control',control_id)
clds = imoc.open()
nlds = network.open()

#show the demand areas
nlds.row_objects('wn_demand_area').each do |da|
	id = da['area_id']
	puts id
end

nlds.transaction_begin()
begin
	hashOptionsPropertyBased = Hash.new
	hashOptionsPropertyBased["update_demand_diagram"] = true;
	hashOptionsPropertyBased["update_demand_in_network"] = true;
	hashOptionsPropertyBased["scale_existing_demand"] = false;
	hashOptionsPropertyBased["update_leakage_in_network"] = true;
	hashOptionsPropertyBased["leakage_items_property_based_demand"] = false;#if false uses avg demad

	hashOptionsDirect = Hash.new
	hashOptionsDirect["update_demand_diagram"] = true;
	hashOptionsDirect["update_leakage_in_network"] = true;
	
	hashOptions = Hash.new
	hashOptions['demand_diagram'] = ddg_id
	hashOptions['live_data_config'] = ldc_id
	
	arr = nlds.update_demand_diagram_and_network(nlds.row_objects('wn_demand_area'),clds,hashOptions, hashOptionsPropertyBased,hashOptionsDirect)
	
	arr.each do | key, value |
		puts "#{key}:#{value}"
	end 
	
	nlds.transaction_commit()
	#commit changes to network
	#network.commit("scripted update");
rescue => exception
	print("#{exception.message}")
	nlds.transaction_rollback()
end

nlds.close()
clds.close()	
database.close()
```

| Name   | Type(s)     | Description                                                                                       |
| ------ | ----------- | ------------------------------------------------------------------------------------------------- |
|**Parameters**|||
| demand_areas    | WSRowObjectCollection   | Demand area row objects                   |
| open_control    | WSOpenNetwork   | The associated control                |
| options   | Hash    | A hash containing general options             |
| optionsPropertyBased    | Hash    | A hash containing options for property based demand |
| optionsDirect   | Hash    | A hash containing options for direct demand         |
|**General options**|||
| demand_diagram  | Long  | Demand Diagram ID             |
| live_data_config  | Long  | Live Data Config ID             |
|**Direct demand options**|||
| update_demand_diagram | Boolean| Update demand diagram                  |
| update_leakage_in_network | Boolean| Update leakage in network            |
|**Property based demand options**|||
| update_demand_diagram | Boolean| Update demand diagram                |
| update_demand_in_network| Boolean| Update demand in network             |
| scale_existing_demand| Boolean| Scale existing demand           |
| update_leakage_in_network | Boolean| Update leakage in network  |
| leakage_items_property_based_demand | Boolean| Update leakage items for property based demand         |

{::/WSPRO}

{::WSPRO}

## validate

```ruby
#validate(scenarios) ⇒ WSValidations
```

`EXCHANGE`, `UI`

Validates a scenario (or multiple scenarios) and returns a `WSValidations` object.

When validating multiple scenarios, the `WSValidation.scenario` method can be used to filter each validation result.

**Parameters**

| Name      | Type(s)                    | Description                                                                                                       |
| --------- | -------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| scenarios | String, Array\<String>, nil | The scenario to validate, an array of scenarios which may include 'base', or nil to validate the 'base' scenario. |
| Return    | WSValidations              |                                                                                                                   |

{::/WSPRO}

{::ICM}

## xprafts_import

```ruby
#xprafts_import(file, use_large_size, split_on_lag_links, combine_subcatchments, log) ⇒ void
```

`EXCHANGE`

Updates the network from an XPRAFTS `.xpx` file.

```ruby
model_group.xprafts_import('C:/temp/1.xpx', true, false, true, 'C:/temp/log.txt')
```

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name                  | Type(s) | Description                                                                                                                                                                                                          |
| --------------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| file                  | String  | The absolute path to the xprafts model, including extension (`.xpx`).                                                                                                                                                |
| use_large_size        | Boolean | If the xprafts model is configured to use the large unit size.                                                                                                                                                       |
| split_on_lag_links    | Boolean | If true networks are split downstream of channel links and maintain lag link data, if false network connectivity is maintained by converting downstream lag links to channel links.                                  |
| combine_subcatchments | Boolean | If true combine the 1st and 2nd subcatchment as a single subcatchment polygon. this would set the per-surface rafts b option and setting the rafts adapt factor and manning's roughness at the runoff surface level. |
| log                   | String  | Path to save the import log including extension (`.txt`).                                                                                                                                                            |

{::/ICM}
