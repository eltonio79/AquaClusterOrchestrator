{ALL}

# WSModelObject

An object that exist in the database tree such as model groups, networks, selection lists, and stored queries.

Methods that return a `WSModelObject` may return a derived class, for example a [WSNumbatNetworkObject](wsnumbatnetworkobject.md) for network types, or [WSSimObject](wssimobject.md) for simulations.

**Methods:**

{{toc}}

## != (Does Not Equal)

```ruby
#!=(other_mo) ⇒ Boolean
```

`EXCHANGE`, `UI`

Checks if this model object is not the same as another model object (inequality check).

## == (Equals)

```ruby
#==(other_mo) ⇒ Boolean
```

`EXCHANGE`, `UI`

Checks if this model object is the same as another model object (equality check).

## [] (Get Field)

```ruby
#[(field)] ⇒ Any
```

`EXCHANGE`, `UI`

Returns the value of a field.

## []= (Set Field)

```ruby
#[(field)]=(value) ⇒ void
```

`EXCHANGE`, `UI`

Sets the value of a field.

**Parameters**

| Name  | Type(s) | Description                                                                                                                               |
| ----- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| field | String  | Name of the field.                                                                                                                        |
| value | Any     | Value to set, if this field references a database object the value can be the id, scripting path, or a wsmodelobject of the correct type. |

## bulk_delete

```ruby
#bulk_delete ⇒ void
```

`EXCHANGE`, `UI`

Permanently deletes the object and all of its children, skipping the recycle bin.

This method works even if the object has children or is used in a simulation, which does not follow the user interface convention. For a safer version of this method, see [#delete](#delete).

## children

```ruby
#children ⇒ WSModelObjectCollection
```

`EXCHANGE`, `UI`

Returns the children of the object.

**Parameters**

| Name   | Type(s)                 | Description |
| ------ | ----------------------- | ----------- |
| Return | WSModelObjectCollection |             |

## comment

```ruby
#comment ⇒ String
```

`EXCHANGE`, `UI`

Returns the comment, a.k.a the description in the user interface.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | String  |             |

## comment= (Set)

```ruby
#comment=(text) ⇒ void
```

`EXCHANGE`, `UI`

Sets the comment, a.k.a the description in the user interface.

**Parameters**

| Name    | Type(s) | Description       |
| ------- | ------- | ----------------- |
| comment | String  | The comment text. |

{::ICM}

## compare

```ruby
#compare(other) ⇒ Boolean
```

`EXCHANGE`

Compares this model object to another, both model objects must be the same type of version controlled object or simulation results.

Simulation results can only be compared if they are both from the current database.

```ruby
if mo.compare(mo2) then
  puts 'Networks are the same!'
else
  puts 'Networks are not the same!'
end
```

**Parameters**

| Name   | Type(s)       | Description                   |
| ------ | ------------- | ----------------------------- |
| other  | WSModelObject | The object to compare.        |
| Return | Boolean       | If the objects are identical. |

{::/ICM}

{::WSPRO}

## compare_demand_diagram

```ruby
#compare_demand_diagram(other) ⇒ Boolean
```

`EXCHANGE`, `UI`

Checks if two demand diagrams are identical. This `WSModelObject` and the object to compare must be a demand diagram.

```ruby
ddg = db.model_object_from_type_and_id('Demand Diagram', 48)
other_ddg = db.model_object_from_type_and_id('Demand Diagram', 213)

compare = ddg.compare_demand_diagram(other_ddg)
puts compare ? 'Demand Diagrams are the same!' : 'Demand Diagrams are different!'
```

**Parameters**

| Name   | Type(s)       | Description                                                  |
| ------ | ------------- | ------------------------------------------------------------ |
| other  | WSModelObject | The other demand diagram, must be a demand diagram.          |
| Return | Boolean       | If the demand diagrams are identical, false if they are not. |

{::/WSPRO}

## copy_here

```ruby
#copy_here(object, copy_sims, copy_ground_models) ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Copies a model object and any children as a child of this object, returning the new model object. The model object being copied could be from the same database, or another database such as a transportable database.

**Parameters**

| Name               | Type(s)       | Description                                                                                               |
| ------------------ | ------------- | --------------------------------------------------------------------------------------------------------- |
| object             | WSModelObject | The model object to copy.                                                                                 |
| copy_results       | Boolean       | Whether to copy simulation results, if the model object (or it's children) have simulations with results. |
| copy_ground_models | Boolean       | Whether to copy ground models.                                                                            |
| Return             | WSModelObject | The newly copied object in this database.                                                                 |

{::ICM}

## csv_import_tvd

```ruby
#csv_import_tvd(file, name, config_file) ⇒ Array
```

`EXCHANGE`

Performs an import of time varying data into an asset group, creating one or more 'time varying data' objects in the same manner as the user interface when the import time varying data from generic CSV option is used.

**Parameters**

| Name        | Type(s) | Description                                 |
| ----------- | ------- | ------------------------------------------- |
| file        | String  | Path to the file.                           |
| name        | String  | Root name of the new object.                |
| config_file | String  | Path to the config file, saved from the ui. |
| Return      | Array   |                                             |

{::/ICM}

## deletable?

```ruby
#deletable? ⇒ Boolean
```

`EXCHANGE`, `UI`

Whether this model object can be deleted using the `#delete` method, which follows the user interface rules: has no children, and is not used in a simulation.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Boolean |             |

## delete

```ruby
#delete ⇒ void
```

`EXCHANGE`, `UI`

Deletes the object, provided it meets the user interface rules: has no children, and is not used in a simulation.

This is a safer alternative to the [#bulk_delete](#bulk_delete) method, which ignores these rules.

{::ICM}

## delete_results

```ruby
#delete_results ⇒ void
```

`EXCHANGE`

Deletes the results, if this object is a simulation.

{::/ICM}

{::ICM}

## export

```ruby
#export(path, format) ⇒ void
```

`EXCHANGE`

Exports the model object in the appropriate format.

The formats permitted depend on the object type. The format string may affect the actual data exported as well as the format in which the data is exported e.g. for rainfall events the parameter 'CRD' means that the Catchment Runoff Data is exported.

When the format is the empty string the data is exported in the InfoWorks text file format. This format may be used for:

- Inflow
- Level
- Infiltration
- Waste Water
- Trade Waste
- Rainfall Event (non-synthetic)
- Pipe Sediment Data
- Observed Flow Event
- Observed Depth Event
- Observed Velocity Event
- Layer List ( this is a different file format but still termed the 'InfoWorks file' in the user interface).
- Regulator (from 6.0)

For rainfall events the following parameters cause the export of other data in a text file format:

- CRD - Catchment Runoff Data
- CSD - Catchment Sediment Data
- EVP - Evaporation
- ISD - Initial Snow Data
- TEM - Temperature Data
- WND - Wind Data

For pollutant graphs the appropriate pollutant graph code causes the export of that pollutant's data in the text file format.

If the format is 'CSV' the file will be exported in 'InfoWorks CSV' format for the following object types:

- Level
- Infiltration
- Inflow
- Observed Flow
- Observed Depth
- Observed Velocity
- Rainfall Event (synthetic - main rainfall data)
- Regulator
- Damage Function (from version 6.5)
- Waste Water (from a version 7.5 patch)
- Trade Waste (from a version 7.5 patch)

The results obtained by risk analysis runs may be exported as follows:

For Risk Analysis Results objects (known in ICM Exchange as Risk Calculation Results) the files may be exported by using the following in the format field:

- "Receptor Damages"
- "Component Damages"
- "Code Damages"
- "Impact Zone Damages"
- "Category Damages"
- "Inundation Depth Results"

For Risk Analysis Sim objects (known in ICM Exchange as Damage Calculation Results) the files may be exported by using the following in the format field:

- "Receptor vs Code"
- "Receptor vs Component"
- "Code vs Component"
- "Impact Zone vs Code"
- "Impact Zone Code vs Component"
- "Category Code vs Component"

For dashboards in InfoAsset Manager the format must be 'html', and the filename the name of the HTML file. Note in this case that other files are exported alongside the html file in the same folder. The names of these files are fixed for each individual dashboard object in the database so exporting the same dashboard object multiple times to different HTML files in the same folder will not give the intended results, you should instead export them to different folders.

**Parameters**

| Name   | Type(s) | Description              |
| ------ | ------- | ------------------------ |
| path   | String  | Path to the export file. |
| format | String  |                          |

{::/ICM}

{::WSPRO}

## export_demand_diagram

```ruby
#export_demand_diagram(filename) ⇒ void
```

`EXCHANGE`, `UI`

Exports the demand diagram to a file. The file extension dictates the data format, which can be `ddg`, `csv`, or `json`.

```ruby
ddg.export_demand_diagram('C:/Badger/demand_diagram.json')
```

This `WSModelObject` must be a demand diagram.

**Parameters**

| Name     | Type(s) | Description                                        |
| -------- | ------- | -------------------------------------------------- |
| filename | String  | Destination filepath including the file extension. |

{::/WSPRO}

## find_child_model_object

```ruby
#find_child_model_object(type, name) ⇒ WSModelObject?
```

`EXCHANGE`, `UI`

Finds a child model object of a given type and name.

**Parameters**

| Name | Type(s) | Description             |
| ---- | ------- | ----------------------- |
| type | String  | The type of the object. |
| name | String  | The name of the object. |

{::WSPRO}

## gmr_clear_test_cases

```ruby
#gmr_clear_test_cases ⇒ void
```

`EXCHANGE`, `UI`

Clears test cases on this GMR object.

**Examples**

```ruby
gmr_config = db.model_object_from_type_and_id('Gen Multi Run Cfg', 1309)
gmr_config_import.gmr_clear_test_cases
```

## gmr_export_test_cases

```ruby
#gmr_export_test_cases(file_name) ⇒ void
```

`EXCHANGE`, `UI`

Exports all test cases to CSV.

**Examples**

```ruby
gmr_config = db.model_object_from_type_and_id('Gen Multi Run Cfg', 1309)
gmr_config.gmr_export_test_cases("D:/CSV/Testcases.csv")
```

**Parameters**

| Name      | Type(s) | Description       |
| --------- | ------- | ----------------- |
| file_name | String  | Path to the file. |

## gmr_import_test_cases

```ruby
#gmr_export_test_cases(file_name) ⇒ void
```

`EXCHANGE`, `UI`

Imports new test cases from CSV, for example from [#gmr_export_test_cases](#gmr_export_test_cases).

**Examples**

```ruby
gmr_config = db.model_object_from_type_and_id('Gen Multi Run Cfg', 1309)
gmr_config_import.gmr_import_test_cases("D:\\CSV\\testcases.csv")
```

**Parameters**

| Name      | Type(s) | Description       |
| --------- | ------- | ----------------- |
| file_name | String  | Path to the file. |

{::/WSPRO}

## id

```ruby
#id ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the ID of this model object.

{::ICM}

## import_all_sw_model_objects

```ruby
#import_all_sw_model_objects(file, format, scenario, logfile) ⇒ Array<WSModelObject>
```

`EXCHANGE`

Imports all SWMM model objects from a supported file. Object types imported:

- SWMM Network
- Inflow
- IWSW Run
- IWSW Time Patterns
- Selection List
- Level
- Rainfall Event
- IWSW pollutograph
- IWSW Climatology
- Regulator

This model object must be of a suitable type to contain the model objects imported.

**Parameters**

| Name     | Type(s)               | Description                                                                                       |
| -------- | --------------------- | ------------------------------------------------------------------------------------------------- |
| file     | String                | Path to the file for import.                                                                      |
| format   | String                | Object format to import, can be `inp` for swmm5, `xpx` for xpswmm/xpstorm, or `mxd` for infoswmm. |
| scenario | String                | Scenario name, only used when importing an `mxd` file.                                            |
| logfile  | String                | Path to a log file, ending with a `.txt` extension.                                               |
| Return   | Array\<WSModelObject> |                                                                                                   |

{::/ICM}

{::ICM}

## import_data

```ruby
#import_data(format, file) ⇒ void
```

`EXCHANGE`

Imports data into this object.

This is only relevant for rainfall events and pollutographs, because they contain multiple pages of data which must be imported and exported separately. You have the choice of either:

- Creating an empty object and importing all the data items using this method
- Importing the first data item into a new object using `#import_new_model_object` and importing subsequent items into the object using this method - in the case of rainfall events the first item must be the rainfall, in the case of pollutographs is can be any item

Both InfoWorks CSV and InfoWorks file formats are supported. The parameter is 'CSV' for CSV files or some other string for the InfoWorks files.

For rainfall events the formats are SMD, EVP, SOL, WND, TEM, CSD, ISD, CRD and RED - for RED you can also put nil or ''. These are as documented in the main product documentation.

For pollutographs the format name is the pollutograph code.

CSV files import into the blob based on data in the CSV file.

For rainfall events the CSV files may only be used for the time varying data i.e Rainfall, Temperature, Wind, Evaporation, Solar Radiation and Soil Moisture Deficit.

```ruby
mo_rain.import_data('CSV', 'C:/temp/MyRain_EVP.csv')
mo_rain.import_data('SMD', 'C:/temp/MyRain.smd')
mo_pollutograph.import_data('CSV', 'C:/temp/P.csv')
```

**Parameters**

| Name   | Type(s) | Description       |
| ------ | ------- | ----------------- |
| format | String  | File format.      |
| file   | String  | Path to the file. |

{::/ICM}

{::WSPRO}

## import_demand_diagram

```ruby
#import_demand_diagram(filename) ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Imports a new demand diagram from a file. The new demand diagram will use the imported file name.

This `WSModelObject` must be a demand diagram group.

**Examples**

```ruby
ddg = ddg_group.import_demand_diagram('C:/Badger/demand_diagram.json')
ddg.name = 'My New Demand Diagram'
```

**Parameters**

| Name     | Type(s)       | Description                                                                                                                                      |
| -------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| filename | String        | Filepath to the demand diagram, including the file extension. the file extension determines the expected input format (`ddg`, `csv`, or `json`). |
| Return   | WSModelObject |                                                                                                                                                  |

{::/WSPRO}

{::ICM}

## import_grid_ground_model

```ruby
#import_grid_ground_model(polygon, files, options) ⇒ void
```

`EXCHANGE`

Imports a gridded ground model. This `WSModelObject` must be a model group or asset group.

The options hash contains the following options:

| Key                |  Type   | Default | Description                                                                     |
| ------------------ | :-----: | :-----: | ------------------------------------------------------------------------------- |
| ground_model_name  | String  |         | Must be non-empty and unique in group                                           |
| data_type          | String  |         | Displayed in the UI                                                             |
| cell_size          |  Float  |    1    | Must be non-zero                                                                |
| unit_multiplier    |  Float  |  0.001  | Must be non-zero                                                                |
| xy_unit_multiplier |  Float  |    1    | Must be non-zero                                                                |
| systematic_error   |  Float  |    0    |                                                                                 |
| use_polygon        | Boolean |  false  | Polygon is only used if this is true, if it is true the polygon must be non-nil |
| integer_format     | Boolean |  true   |                                                                                 |

```ruby
model_group = database.model_object_from_type_and_id('Model Group', 2)
files = ['C:/temp/small_grid.asc']
options = {
  'ground_model_name' => 'my_ground_model',
  'data_type' => 'badger',
  'cell_size' => 5.0,
  'unit_multiplier' => 1.0,
  'xy_multiplier' => 1.0,
  'integer_format' => false,
  'use_polygon' => false
}
model_group.import_grid_ground_model(nil, files, options)
```

**Parameters**

| Name    | Type(s)          | Description                                                                              |
| ------- | ---------------- | ---------------------------------------------------------------------------------------- |
| polygon | WSRowObject, nil | An object with polygon geometry from a currently open [WSOpenNetwork](wsopennetwork.md). |
| files   | Array\<String>   | Array of file paths.                                                                     |
| options | Hash             | See method description.                                                                  |

{::/ICM}

{::ICM}

## import_infodrainage_object

```ruby
#import_infodrainage_object(file, type, log) ⇒ WSModelObject
```

`EXCHANGE`

Imports an InfoDrainage object. This `WSModelObject` must be a model group.

**Parameters**

| Name   | Type(s)       | Description                                                       |
| ------ | ------------- | ----------------------------------------------------------------- |
| file   | String        | Path to the infodrainagae file to import, with `.idxx` extension. |
| type   | String        | Type of object to import, the only accepted value is `inflow`.    |
| log    | String        | Path to save the import log.                                      |
| Return | WSModelObject |                                                                   |

{::/ICM}


{::WSPRO}

## import_layer_list

```ruby
#import_layer_list(new_object_name, file_name) ⇒ void
```

`EXCHANGE`, `UI`

Imports a layer list.

**Parameters**

| Name   | Type(s)       | Description          |
| ------ | ------------- | --------------------- |
| new_object_name	   | String        | Name of the new layer list in the tree. |
| file_name   | String        | Path to the layer list file.    |

{::/WSPRO}

{::ICM}

## import_new_model_object

```ruby
#import_new_model_object(type, name, format, file, event) ⇒ WSModelObject
```

`EXCHANGE`

Imports a new model object from a file, as a child of this `WSModelObject`. This must be a suitable type to contain the new model object.

Permitted types are:

- Inflow
- Level
- Ground Infiltration
- Waste Water
- Trade Waste
- Rainfall Event (non-synthetic)
- Pipe Sediment Data
- Observed Flow Event
- Observed Depth Event
- Observed Velocity Event
- Layer List (this is a different file format but still termed the 'InfoWorks file' in the user interface)
- Regulator
- Damage Function
- Pollutograph

Permitted formats are:

- An empty string - for InfoWorks format files
- CSV for InfoWorks format CSV files (not available for layer lists, or damage functions)
- CSV for Pollutographs (the data imported will depend on the CSV file)
- The 3 letter pollutograph code

You can only import one pollutant, if you wish to import more into the same InfoWorks object you can use the `#import_data` method. You can also use that method to import additional data into Rainfall Events.

```ruby
rainfall = model_group.import_new_model_object('Rainfall Event', 'The Rainfall', '', 'C:/temp/1.red')
```

**Parameters**

| Name   | Type(s)       | Description                                             |
| ------ | ------------- | ------------------------------------------------------- |
| type   | String        | See method description for list of supported types.     |
| name   | String        | Name of the imported object.                            |
| format | String        | See method description for list of supported formats.   |
| file   | String        | Path to the file.                                       |
| event  | Integer       | Optional from version 11.5, should be set to 0 if used. |
| Return | WSModelObject |                                                         |

{::/ICM}

{::ICM}

## import_new_model_object_from_generic_csv_files

```ruby
#import_new_model_object_from_generic_csv_files(type, name, file, config) ⇒ Array<WSModelObject, String>
```

`EXCHANGE`

Imports a new model object using the generic CSV importer, as a child of this `WSModelObject`. This must be a suitable type to contain the new model object.

It requires a config file previously set up in the UI.

Permitted types are:

- Inflow
- Level
- Infiltration
- Rainfall Event (non-synthetic)
- Pipe Sediment Data
- Observed Flow Event
- Observed Depth Event
- Observed Velocity Event
- Regulator

The return value is an array with 2 elements. The first element is the `WSModelObject` created. The second element is either nil or a string of the warning message that would appear in the UI .

**Parameters**

| Name   | Type(s)                      | Description                                                                                                            |
| ------ | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| type   | String                       | See method description for list of supported types.                                                                    |
| name   | String                       | Used as a prefix for the event name (ignored for multiple rainfall events).                                            |
| file   | String, Array\<String>       | A single file path, or an array of file paths which matches the ui behaviour of 'import multiple files into an event'. |
| config | String                       | Path to the config file.                                                                                               |
| Return | Array<WSModelObject, String> |                                                                                                                        |

{::/ICM}

{::ICM}

## import_new_sw_model_object

```ruby
#import_new_sw_model_object(type, format, file, scenario, log) ⇒ WSModelObject
```

`EXCHANGE`

Imports a new SWMM model object as a child of this `WSModelObject`. This must be a suitable type to contain the new model object.

Permitted types are:

- Inflow
- IWSW Run
- IWSW Time Patterns
- Selection List
- Level
- Rainfall Event
- IWSW pollutograph
- IWSW Climatology
- Regulator

```ruby
new_swmm = model_group.import_new_sw_model_object('Rainfall Event', 'INP', 'C:/temp/1.inp', '', 'C:/temp/log.txt')
```

**Parameters**

| Name     | Type(s)       | Description                                                                                       |
| -------- | ------------- | ------------------------------------------------------------------------------------------------- |
| type     | String        | See method description for list of supported types.                                               |
| format   | String        | Object format to import, can be `inp` for swmm5, `xpx` for xpswmm/xpstorm, or `mxd` for infoswmm. |
| file     | String        | Path to the file for import.                                                                      |
| scenario | String        | Scenario name, only used when importing an `mxd` file.                                            |
| log      | String        | Path to a log file, ending with a `.txt` extension.                                               |
| Return   | WSModelObject |                                                                                                   |

{::/ICM}

{::WSPRO}

## import_synergi

```ruby
#import_synergi(file, network_name, control_name, ddg_group_name, selection_list_group_name, run_group_name, html_file_name, use_ace) ⇒ void
```

`EXCHANGE`, `UI`

Import a Synergi model, equivalent to the import feature in the user interface.

**Parameters**

| Name                | Type(s) | Description                                                                                                                                                                                                                                                                                                      |
| ------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| filename            | String  | File path to the synergi model (.mdb) that will be imported.                                                                                                                                                                                                                                                     |
| network_name        | String  | Name for the new network.                                                                                                                                                                                                                                                                                        |
| control_name        | String  | Name for the new control.                                                                                                                                                                                                                                                                                        |
| ddg_group_name      | String  | Name for the new demand diagram group.                                                                                                                                                                                                                                                                           |
| selection_list_name | String  | Name for the new selection list group.                                                                                                                                                                                                                                                                           |
| run_group_name      | String  | Name for the new run group.                                                                                                                                                                                                                                                                                      |
| html_file_name      | String  | File path for the html file where the import log should be written.                                                                                                                                                                                                                                              |
| use_ace             | Boolean | Boolean indicating if ace (access database engine) should be used for the import, which must be installed. this is the only supported method for 64bit Innovyze and autodesk software versions.<br><br>if false the application will use jet database engine which is only supported on 32 bit (Innovyze licensing). |

{::/WSPRO}

{::ICM}

## import_tvd

```ruby
#import_tvd(file, format, event) ⇒ void
```

`EXCHANGE`

Imports event data into an existing object.

If the format is 'CSV' this expects the 'InfoWorks CSV file' format, and imports this into an existing event, overwriting any data already there.

If the format is 'RED' and the type of the object is a rainfall event, this will import the data in event file format into an existing event, overwriting any data already there.

**Parameters**

| Name   | Type(s) | Description                      |
| ------ | ------- | -------------------------------- |
| file   | String  | Path to the file to be imported. |
| format | String  | Either `csv` or `red`.           |
| event  | Integer | Must be present but is ignored.  |

{::/ICM}

## modified_by

```ruby
#modified_by ⇒ String
```

`EXCHANGE`, `UI`

Returns the username which last modified the object. This may be different from the latest commit of a version controlled network.

## name

```ruby
#name ⇒ String
```

`EXCHANGE`, `UI`

Returns the name of this object.

## name= (Set)

```ruby
#name=(new_name) ⇒ void
```

`EXCHANGE`, `UI`

Sets the name of this object.

**Parameters**

| Name     | Type(s) | Description |
| -------- | ------- | ----------- |
| new_name | String  |             |

## new_model_object

```ruby
#new_model_object(type, name) ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Creates a new model object as a child of this object - the type must be valid for this object.

Scripts that are running in the user interface are unable to create most types of model objects, the only exceptions being Selection Lists and Selection List Groups. The full functionality of this method is only available in Exchange.

{::ICM}
Runs cannot be created using this method, they are created using [#new_run](#new_run) or [#new_risk_analysis_run](#new_risk_analysis_run).
{::/ICM}

{::WSPRO}
Runs cannot be created using this method, they are created using a [WSRunScheduler](wsrunscheduler.md) object.
{::/WSPRO}

**Parameters**

| Name | Type(s) | Description                   |
| ---- | ------- | ----------------------------- |
| type | String  | Type of the new model object. |
| name | String  | Name of the new model object. |

**Exceptions**

- **unrecognised type** - if the type is not a valid scripting type
- **sims cannot be created directly** - if an attempt is made to create a sim
- **invalid child type for this object** - if the new type may not be a child of this object type
- **name already in use** - if the name is in use by another model object (that is also a child of this object), or globally if this is a version controlled type with a standalone database
- **licence and/or permissions do not permit creation of a child of this type for this object** - if this type of object cannot be created for licensing and/or permissions reasons
- **unable to create object** - if the call fails for some other reason

{::ICM}

## new_risk_analysis_run

```ruby
#new_risk_analysis_run(name, damage_function, runs, param) ⇒ WSRiskAnalysisRunObject
```

`EXCHANGE`

Creates a new risk analysis run object.

**Parameters**

| Name            | Type(s)                                                                                | Description                                                                                                                                                        |
| --------------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| name            | String                                                                                 | Name of the new object.                                                                                                                                            |
| damage_function | Integer, String, WSModelObject                                                         | The damage function object - can be the id, scripting path, or a wsmodelobject of the correct type.                                                                |
| runs            | Integer, Array\<Integer>, String, Array\<String>, WSModelObject, Array\<WSModelObject> | The run object, or array of run objects - can be the id, scripting path, or a wsmodelobject of the correct type (all elements in the array must be the same type). |
| param           | Numeric                                                                                | The numerical parameter.                                                                                                                                           |
| Return          | WSRiskAnalysisRunObject                                                                |                                                                                                                                                                    |

{::/ICM}

{::ICM}

## new_run

```ruby
#new_run(name, network, commit_id, rainfalls_and_flow_surveys, scenarios, options) => WSModelObject
```

`EXCHANGE`

Creates a new run. This `WSModelObject` must be a model group.

The method can take arrays as parameters for both the rainfalls and flow surveys and for the scenarios. In the same way that dropping multiple rainfall events and flow surveys into the drop target on the schedule run dialog and selecting multiple scenarios on it yield multiple simulations for a run, so calling this method with arrays of values and with synthetic rainfall events which have multiple parameters (singly or in an array) will yield multiple sims for the run.

The `#run` method which actually runs simulations is a method of the individual sim objects below the run, which can be accessed by using the `#children` method of the `WSModelObject` returned by this method.

The rainfalls_and_flow_surveys parameter can be:

- nil - in this case the run will be a dry weather flow run
- a WSModelObject which is a rainfall event or a flow survey
- the scripting path of a rainfall event or a flow survey as a string
- the ID of a rainfall event
- a negative number equal to -1 times the ID of a flow survey e.g. -7 means the Flow Survey with ID 7.
- An array. If the parameter is an array, then if the length of the array is 0 then the event will be a dry weather flow run, otherwise all the array elements must be one of 2 - 5 above. The array may not contain duplicates otherwise an exception will be thrown.

**Parameters**

| Name                       | Type(s)                        | Description                                                                                                                                               |
| -------------------------- | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name                       | String                         | The name of the new run, this must be unique within the model group.                                                                                      |
| network                    | Integer, String, WSModelObject | The network used for the run - can be the id, scripting path, or a wsmodelobject of the correct type.                                                     |
| commit_id                  | Integer, nil                   | The commit id to be used for the run, this can be the integer commit id, or nil in which case the latest commit is used.                                  |
| rainfalls_and_flow_surveys | Multiple                       | See method description.                                                                                                                                   |
| scenarios                  | String, Array\<String>, nil    | Nil to use the base scenario, the name of the scenario, or an array f scenario names (which must not contain duplicates, or scenarios that do not exist). |
| options                    | Hash                           | A hash containing run options.                                                                                                                            |

**Exceptions**

- **new_run : runs may only be created in model groups** - the run must only be created in a model group
- **new_run : name already in use** - if the run name is already in use

{::/ICM}

{::ICM}

## new_synthetic_rainfall

```ruby
#new_synthetic_rainfall(name , type, params) ⇒ void
```

`EXCHANGE`

Creates a new synthetic rainfall model object as a child of this WSModelObject. 
Permitted generator types are:
- UKRain
- FEHRain
- ReFHRain
- GermanRain
- HKRain
- HK5thEdRain
- AUSRain
- FRQRain
- FRRain
- MYRain
- MY2015Rain
- USRain
- ChineseRain
- ChicagoRain

The params hash contains the following.

| Key                   | Type    | Default | Description                   |
| --------------------- | ------- | ------- | ----------------------------- |
| Location              | Integer |         | UKRain                        |
| Profile               | Integer |         | UKRain                        |
| WetnessIndex          | Integer |         | UKRain                        |
| Series                | Integer |         | UKRain                        |
| 5yr1hr                | Float   |         | UKRain                        |
| RainfallRatio         | Float   |         | UKRain                        |
| API30                 | Float   |         | UKRain                        |
| SMS                   | Float   |         | UKRain                        |
| SMD                   | Float   |         | UKRain                        |
| Cini                  | Float   |         | UKRain                        |
| BF0                   | Float   |         | UKRain                        |
| Evaporation           | Float   |         | UKRain                        |
| CatchmentArea         | Float   |         | UKRain                        |
| Profile               | Integer |         | FEHRain, ReFHRain, GermanRain |
| WetnessIndex          | Integer |         | FEHRain, ReFHRain, GermanRain |
| ReturnPeriodType      | Integer |         | FEHRain, ReFHRain, GermanRain |
| ReturnPeriod          | Float   |         | FEHRain, ReFHRain, GermanRain |
| Duration              | Float   |         | FEHRain, ReFHRain, GermanRain |
| Antecedentdepth       | Float   |         | FEHRain, ReFHRain, GermanRain |
| UCWI                  | Float   |         | FEHRain, ReFHRain, GermanRain |
| API30                 | Float   |         | FEHRain, ReFHRain, GermanRain |
| SMS                   | Float   |         | FEHRain, ReFHRain, GermanRain |
| SMD                   | Float   |         | FEHRain, ReFHRain, GermanRain |
| Cini                  | Float   |         | FEHRain, ReFHRain, GermanRain |
| BF0                   | Float   |         | FEHRain, ReFHRain, GermanRain |
| Evaporation           | Float   |         | FEHRain, ReFHRain, GermanRain |
| WetnessIndex          | Integer |         | HKRain, HK5thEdRain           |
| Method                | Integer |         | HKRain, HK5thEdRain           |
| ReturnPeriod          | Float   |         | HKRain, HK5thEdRain           |
| Duration              | Float   |         | HKRain, HK5thEdRain           |
| Antecedentdepth       | Float   |         | HKRain, HK5thEdRain           |
| UCWI                  | Float   |         | HKRain, HK5thEdRain           |
| API30                 | Float   |         | HKRain, HK5thEdRain           |
| SMS                   | Float   |         | HKRain, HK5thEdRain           |
| SMD                   | Float   |         | HKRain, HK5thEdRain           |
| Cini                  | Float   |         | HKRain, HK5thEdRain           |
| BF0                   | Float   |         | HKRain, HK5thEdRain           |
| Evaporation           | Float   |         | HKRain, HK5thEdRain           |
| A                     | Float   |         | HKRain, HK5thEdRain           |
| B                     | Float   |         | HKRain, HK5thEdRain           |
| C                     | Float   |         | HKRain, HK5thEdRain           |
| WetnessIndex          | Integer |         | AUSRain                       |
| Zone                  | Float   |         | AUSRain                       |
| 2 yr 1 hour           | Float   |         | AUSRain                       |
| 2 yr 12 hour          | Float   |         | AUSRain                       |
| 2 yr 72 hour          | Float   |         | AUSRain                       |
| 50 yr 1 hour          | Float   |         | AUSRain                       |
| 50 yr 12 hour         | Float   |         | AUSRain                       |
| 50 yr 72 hour         | Float   |         | AUSRain                       |
| 2 yr 6 minutes        | Float   |         | AUSRain                       |
| 50 yr 6 minutes       | Float   |         | AUSRain                       |
| Coefficient           | Float   |         | AUSRain                       |
| UCWI                  | Float   |         | AUSRain                       |
| API30                 | Float   |         | AUSRain                       |
| SMS                   | Float   |         | AUSRain                       |
| SMD                   | Float   |         | AUSRain                       |
| Cini                  | Float   |         | AUSRain                       |
| BF0                   | Float   |         | AUSRain                       |
| Evaporation           | Float   |         | AUSRain                       |
| Antecedentdepth       | Float   |         | AUSRain                       |
| Enable Lan / Long     | Float   |         | AUSRain                       |
| Latitude              | Float   |         | AUSRain                       |
| Longitude             | Float   |         | AUSRain                       |
| ARI                   | Float   |         | AUSRain                       |
| Duration              | Float   |         | AUSRain                       |
| Multiplying Factor    | Float   |         | AUSRain                       |
| WetnessIndex          | Integer |         | FRRain                        |
| Location              | Integer |         | FRRain                        |
| ReturnPeriod          | Float   |         | FRRain                        |
| PeakDuration          | Float   |         | FRRain                        |
| Antecedentdepth       | Float   |         | FRRain                        |
| UCWI                  | Float   |         | FRRain                        |
| API30                 | Float   |         | FRRain                        |
| SMS                   | Float   |         | FRRain                        |
| SMD                   | Float   |         | FRRain                        |
| Cini                  | Float   |         | FRRain                        |
| BF0                   | Float   |         | FRRain                        |
| Evaporation           | Float   |         | FRRain                        |
| PeakPosition          | Float   |         | FRRain                        |
| A                     | Float   |         | FRRain                        |
| B                     | Float   |         | FRRain                        |
| Profile               | Integer |         | FRQRain                       |
| WetnessIndex          | Integer |         | FRQRain                       |
| Antecedentdepth       | Float   |         | FRQRain                       |
| UCWI                  | Float   |         | FRQRain                       |
| API30                 | Float   |         | FRQRain                       |
| SMS                   | Float   |         | FRQRain                       |
| SMD                   | Float   |         | FRQRain                       |
| Cini                  | Float   |         | FRQRain                       |
| BF0                   | Float   |         | FRQRain                       |
| Evaporation           | Float   |         | FRQRain                       |
| PeakPosition          | Float   |         | FRQRain                       |
| PeakDuration          | Float   |         | FRQRain                       |
| Intensity             | Float   |         | FRQRain                       |
| PeakRainfall          | Float   |         | FRQRain                       |
| StormRainfall         | Float   |         | FRQRain                       |
| Timestep              | Float   |         | FRQRain                       |
| Duration              | Float   |         | FRQRain                       |
| StartTime             | Float   |         | FRQRain                       |
| EndTime               | Float   |         | FRQRain                       |
| WetnessIndex          | Integer |         | MYRain, MY2015Rain            |
| Location              | Integer |         | MYRain, MY2015Rain            |
| ReturnPeriod          | Float   |         | MYRain, MY2015Rain            |
| Duration              | Float   |         | MYRain, MY2015Rain            |
| Antecedentdepth       | Float   |         | MYRain, MY2015Rain            |
| UCWI                  | Float   |         | MYRain, MY2015Rain            |
| API30                 | Float   |         | MYRain, MY2015Rain            |
| SMS                   | Float   |         | MYRain, MY2015Rain            |
| SMD                   | Float   |         | MYRain, MY2015Rain            |
| Cini                  | Float   |         | MYRain, MY2015Rain            |
| BF0                   | Float   |         | MYRain, MY2015Rain            |
| Evaporation           | Float   |         | MYRain, MY2015Rain            |
| A                     | Float   |         | MYRain, MY2015Rain            |
| B                     | Float   |         | MYRain, MY2015Rain            |
| C                     | Float   |         | MYRain, MY2015Rain            |
| D                     | Float   |         | MYRain, MY2015Rain            |
| CatchmentArea         | Float   |         | MYRain, MY2015Rain            |
| 2P24hr                | Float   |         | MYRain                        |
| WetnessIndex          | Integer |         | USRain                        |
| SCSInPat              | Integer |         | USRain                        |
| SCSDur                | Integer |         | USRain                        |
| Antecedentdepth       | Float   |         | USRain                        |
| UCWI                  | Float   |         | USRain                        |
| API30                 | Float   |         | USRain                        |
| SMS                   | Float   |         | USRain                        |
| SMD                   | Float   |         | USRain                        |
| Cini                  | Float   |         | USRain                        |
| BF0                   | Float   |         | USRain                        |
| Evaporation           | Float   |         | USRain                        |
| SCS24Rain             | Float   |         | USRain                        |
| SCSTS                 | Float   |         | USRain                        |
| CalculationOfA        | Integer |         | ChineseRain                   |
| ReturnPeriod          | Float   |         | ChineseRain                   |
| Duration              | Float   |         | ChineseRain                   |
| PeakTimeRatio         | Float   |         | ChineseRain                   |
| BigA                  | Float   |         | ChineseRain                   |
| SmlA                  | Float   |         | ChineseRain                   |
| SmlB                  | Float   |         | ChineseRain                   |
| C                     | Float   |         | ChineseRain                   |
| SmlN                  | Float   |         | ChineseRain                   |
| Timestep              | Float   |         | ChineseRain                   |
| ReturnPeriod          | Float   |         | ChicagoRain                   |
| Duration              | Float   |         | ChicagoRain                   |
| PeakTimeRatio         | Float   |         | ChicagoRain                   |
| A                     | Float   |         | ChicagoRain                   |
| B                     | Float   |         | ChicagoRain                   |
| C                     | Float   |         | ChicagoRain                   |
| Timestep              | Float   |         | ChicagoRain                   |


**Parameters**

| Name      | Type(s) | Description                                           |
| --------- | ------- | ----------------------------------------------------- |
| name      | String  | Name of the new model object.                         |
| type      | String  | Generator type of the new rainfall model object.      |
| params    | Hash    | A hash containing rainfall parameters.                |

**Exceptions**

- **synthetic rainfall events may only be created in model groups** : the rainfall event must be created in a model group.
- **name already in use** : if the rainfall event name is already in use.
- **rainfall type XXXX cannot be created by scripting** : input type one of the following FEH2013, FEH2022, AUS2016Rain, NOAARain which cannot be created using scripting since they need external software.
- **rainfall type XXXX not found** : input type not valid.
- **parameter 3 is not a Hash** : input params is not a valid hash.
- **unable to load DLL** : problem loading rainfall generator software.

{::/ICM}

## open

```ruby
#open ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Only available for model objects of a network type or sim.

Opens the network and returns a [WSOpenNetwork](./wsopennetwork.md) object. When this method is called on a sim, the network and results are opened. An exception will be thrown if the simulation did not succeed or the results are inaccessible.

Note that when you open the results of a simulation:

- The network is opened as read only
- The current scenario is set to the scenario used for the simulation
- The current scenario cannot be changed
- As with the behaviour in the UI of the software, the network with the results loaded has a current timestep. The results start by being opened at the first timestep (timestep 0) unless there are only maximum results in which case they are opened as the maximum results timestep.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | WSModelObject |             |

## parent_id

```ruby
#parent_id ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the ID of this object's parent. This will be 0 if the object is in the root of the database.

## parent_type

```ruby
#parent_type ⇒ String
```

`EXCHANGE`, `UI`

Returns the type of this object's parent. This will be 'Master Database' if the object is in the root of the database.

## path

```ruby
#path ⇒ String
```

`EXCHANGE`, `UI`

Returns the scripting path of this object.

{::WSPRO}

## status

```ruby
#status ⇒ Integer
```

`EXCHANGE`, `UI`

Gets the value of the status field.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

{::/WSPRO}

{::WSPRO}

## status= (Set)

```ruby
#status=(i) ⇒ void
```

`EXCHANGE`, `UI`

Sets the value of the status field. This field is not visible in the user interface and can be used for any purpose.

An example use case is for automated tasks such as model building, where you can store the outcome against the model object so that other scripts can read it. In this use case, the integers would map to a known status code which you define e.g.

- 0 : Success
- 1 : Warnings
- 2 : Error

**Parameters**

| Name | Type(s) | Description      |
| ---- | ------- | ---------------- |
| i    | Integer | The status code. |

{::/WSPRO}

## type

```ruby
#type ⇒ String
```

`EXCHANGE`, `UI`

Returns the type of this model object.

{::WSPRO}

## update_demand_from_live_data

```ruby
#update_demand_from_live_data(live_data_id, live_data_commit_id, mode, categories, start_end, end_date, test_only) ⇒ void
```

`EXCHANGE`, `UI`

Updates a demand diagram from live data.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| live_data_id	       | Integer | The live data configuration model object ID.    |
| live_data_commit_id	 | Integer | The live data configuration commit ID.       |
| mode                 | Integer | 0 = update existing, 1 = all flow live data points, 2 = use list of live data points            |
| categories | String[]	 | Array of categories to be updated.             |
| start_end  | DateTime	 | Start date and time.            |
| end_date   | DateTime	 | End date and time.            |
| test_only	 | Boolean | Only test the update, do not apply changes to the demand diagram.            |

{::/WSPRO}

{::ICM}

## update_to_latest

```ruby
#update_to_latest ⇒ void
```

`EXCHANGE`

Updates a run model object, equivalent to the 'update to latest version of network' button in the run view of the user interface. The following conditions apply:

- The 'Working' field must be set to true
- There must be no uncommitted changes for the network used in the run
- All scenarios that were included in the scenarios list must be present and validated

{::/ICM}
