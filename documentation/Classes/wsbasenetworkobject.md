{ALL}

# WSBaseNetworkObject

[WSModelObject](./wsmodelobject.md) > WSBaseNetworkObject

**Methods:**

{{toc}}

{::WSPRO}

## associated_control_id

```ruby
#associated_control_id ⇒ Integer?
```

`EXCHANGE`, `UI`

Returns the associated control ID.

{::/WSPRO}


{::WSPRO}

## associated_control_id= (Set)

```ruby
#associated_control_id=(id) ⇒ void
```

`EXCHANGE`, `UI`

Sets the associated control ID.

**Parameters**

| Name     | Type(s)     | Description                                        |
| -------- | ----------- | -------------------------------------------------- |
| id     | Integer      | The associated control id.                          |

{::/WSPRO}


{::WSPRO}

## associated_demand_diagram_id

```ruby
#associated_demand_diagram_id ⇒ Integer?
```

`EXCHANGE`, `UI`

Returns the associated demand diagram ID.

{::/WSPRO}


{::WSPRO}

## associated_demand_diagram_id= (Set)

```ruby
#associated_demand_diagram_id=(id) ⇒ void
```

`EXCHANGE`, `UI`

Sets the associated demand diagram ID.

**Parameters**

| Name     | Type(s)     | Description                                        |
| -------- | ----------- | -------------------------------------------------- |
| id     | Integer      | The associated demand diagram id                    |

{::/WSPRO}


{::WSPRO}

## associated_live_data_configuration_id

```ruby
#associated_live_data_configuration_id ⇒ Integer?
```

`EXCHANGE`, `UI`

Returns the associated live data configuration ID.

{::/WSPRO}


{::WSPRO}

## associated_live_data_configuration_id= (Set)

```ruby
#associated_live_data_configuration_id=(id) ⇒ void
```

`EXCHANGE`, `UI`

Sets the associated live data configuration ID.

**Parameters**

| Name     | Type(s)     | Description                                        |
| -------- | ----------- | -------------------------------------------------- |
| id     | Integer      | The associated live data configuration id.          |

{::/WSPRO}

{::WSPRO}

## build_model

Refer to the same method in [WSOpenNetwork](wsopennetwork.md) class.

{::/WSPRO}

## csv_export

```ruby
#csv_export(file, options) ⇒ void
```

`EXCHANGE`, `UI`

Exports the network to a CSV file, with options similar to those in the user interface.

The options hash contains the following keys:

{::ICM}

| Key                      |  Type   | Default  | Notes                                                                      |
| ------------------------ | :-----: | :------: | -------------------------------------------------------------------------- |
| Use Display Precision    | Boolean |   true   |                                                                            |
| Field Descriptions       | Boolean |  false   |                                                                            |
| Field Names              | Boolean |   true   |                                                                            |
| Flag Fields              | Boolean |   true   |                                                                            |
| Multiple Files           | Boolean |  false   | Set to true to export to different files, false to export to the same file |
| Native System Types      | Boolean |  false   |                                                                            |
| User Units               | Boolean |  false   |                                                                            |
| Object Types             | Boolean |  false   |                                                                            |
| Selection Only           | Boolean |  false   |                                                                            |
| Units Text               | Boolean |  false   |                                                                            |
| Triangles                | Boolean |  false   |                                                                            |
| Coordinate Arrays Format | String  | 'Packed' | 'Packed', 'None', or 'Separate'                                            |
| Other Arrays Format      | String  | 'Packed' | 'Packed', 'None', or 'Unpacked'                                            |
| WGS84                    | Boolean |  false   | Export coordinates as WGS84                                                |

{::/ICM}

{::WSPRO}

| Key                      |  Type   | Default  | Notes                                                                      |
| ------------------------ | :-----: | :------: | -------------------------------------------------------------------------- |
| Use Display Precision    | Boolean |   true   |                                                                            |
| Field Descriptions       | Boolean |  false   |                                                                            |
| Field Names              | Boolean |   true   |                                                                            |
| Flag Fields              | Boolean |   true   |                                                                            |
| Multiple Files           | Boolean |  false   | Set to true to export to different files, false to export to the same file |
| User Units               | Boolean |  false   |                                                                            |
| Object Types             | Boolean |  false   |                                                                            |
| Selection Only           | Boolean |  false   |                                                                            |
| Units Text               | Boolean |  false   |                                                                            |
| Coordinate Arrays Format | String  | 'Packed' | 'Packed', 'None', or 'Separate'                                            |
| Other Arrays Format      | String  | 'Packed' | 'Packed', 'None', or 'Unpacked'                                            |
| WGS84                    | Boolean |  false   | Export coordinates as WGS84                                                |

{::/WSPRO}

**Examples**

```ruby
options = {
  'Multiple Files' => true,
  'Coordinate Arrays Format' => 'None'
}

network.csv_export('C:/Badger/my_csv.csv', options)
```

**Parameters**

| Name    | Type(s)   | Description                                                   |
| ------- | --------- | ------------------------------------------------------------- |
| file    | String    | Path to the csv file.                                         |
| options | Hash, nil | Options hash (see description), or nil to use default values. |

## csv_import

```ruby
#csv_import(file, options) ⇒ void
```

`EXCHANGE`, `UI`

Updates the network from a CSV file, with options similar to those in the user interface.

The options hash uses the following keys:

| Key                  |  Type   | Default | Notes                                                                                                                 |
| -------------------- | :-----: | :-----: | --------------------------------------------------------------------------------------------------------------------- |
| Force Link Rename    | Boolean |  true   |                                                                                                                       |
| Flag Genuine Only    | Boolean |  false  |                                                                                                                       |
| Load Null Fields     | Boolean |  true   |                                                                                                                       |
| Update With Any Flag | Boolean |  true   | True to update all values, false to only update fields with the 'update flag' flag                                    |
| Use Asset ID         | Boolean |  false  |                                                                                                                       |
| User Units           | Boolean |  true   | Set to true for User Units, false for Native Units - used for fields without an explicit unit set in a 'units' record |
| UK Dates             | Boolean |  false  | If set to true, the import is done with the UK date format for dates regardless of the PC's settings                  |
| Action               | String  | 'Mixed' | One of 'Mixed', 'Update And Add', 'Update Only', or 'Delete'                                                          |
| Header               | String  |  'ID'   | One of 'ID', 'ID Description', 'ID Description Units', or 'ID Units'                                                  |
| New Flag             | String  |   nil   | Flag used for new and updated data                                                                                    |
| Update Flag          | String  |   nil   | If the 'update with any flag' option is set to false, only update fields with this flag value                         |

**Examples**

```ruby
options = {
  'Use Asset ID' => true,
  'New Flag' => 'NEW'
}

network.csv_import('C:/Badger/my_csv.csv', options)
```

**Parameters**

| Name    | Type(s)   | Description                                                   |
| ------- | --------- | ------------------------------------------------------------- |
| file    | String    | Path to the csv file.                                         |
| options | Hash, nil | Options hash (see description), or nil to use default values. |

## odec_export_ex

```ruby
#odec_export_ex(format, config, options, table, *args) ⇒ void
```

`EXCHANGE`, `UI`

Exports network data using the Open Data Export Centre.

The supported formats are `CSV`, `TSV`, `XML`, `MDB`, `SHP`, `TAB`, `GDB`, `FILEGDB`, `ORACLE`, and `SQLSERVER`. The format used determines the number of additional arguments in the method, which are detailed below.

The options hash uses the following keys:

{::ICM}

| Key                   |    Type    | Default  | Notes                                                  |
| --------------------- | :--------: | :------: | ------------------------------------------------------ |
| Error File            |   String   |   nil    |                                                        |
| Image Folder          |   String   |    ''    | Asset Networks Only                                    |
| Units Behaviour       |   String   | 'Native' | 'Native' or 'User'                                     |
| Report Mode           |  Boolean   |  false   | True to export in 'report mode'                        |
| Append                |  Boolean   |  false   | True to enable ‘Append to existing data’               |
| Export Selection      |  Boolean   |  false   | True to export the selected objects only               |
| Previous Version      |  Integer   |    0     | Previous version, if not zero differences are exported |
| Callback Class        | Ruby Class |   nil    |                                                        |
| Create Primary Key    |  Boolean   |  false   |                                                        |
| Previous Version      |  Integer   |    0     |                                                        |
| Append                |  Boolean   |  false   |                                                        |
| WGS84                 |  Boolean   |  false   | Shapefile only                                         |
| Don't Update Geometry |  Boolean   |  false   |                                                        |

{::/ICM}

{::WSPRO}

| Key                   |  Type   | Default  | Notes                                                         |
| --------------------- | :-----: | :------: | ------------------------------------------------------------- |
| Error File            | String  |   nil    | Path to a text file, which the error log will be appended to. |
| Units Behaviour       | String  | 'Native' | 'Native' or 'User'                                            |
| Report Mode           | Boolean |  false   | True to export in 'report mode'                               |
| Append                | Boolean |  false   | True to enable 'Append to existing data'                      |
| Export Selection      | Boolean |  false   | True to export the selected objects only                      |
| Previous Version      | Integer |    0     | Previous version, if not zero differences are exported        |
| Script File           | String  |   nil    | Path to a VBScript (.bas) file                                |
| Don't Update Geometry | Boolean |  false   |                                                               |

{::/WSPRO}

### Data Export for CSV (Comma Separated Values)

```ruby
#odic_export_ex(format, config, options, table, file)
```

Exports data to a Comma Separated Values file.

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `CSV`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)       |
| file    | String    |         | the absolute filepath to the export file, including extension e.g. "C:/Temp/Badger.csv"                         |

### Data Export for TSV (Tab Separated Values)

```ruby
#odic_export_ex(format, config, options, table, file)
```

Exports data to a Tab Separated Values file.

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `TSV`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)       |
| file    | String    |         | the absolute filepath to the export file, including extension e.g. "C:/Temp/Badger.csv" or "C:/Temp/Badger.tsv" |

### Data Export for XML (Extensible Markup Language)

```ruby
#odic_export_ex(format, config, options, table, feature_class, feature_dataset, filename)
```

Exports data to an XML (Extensible Markup Language) file.

**Parameters**

| Name            | Type(s)   | Default | Description                                                                                                     |
| --------------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format          | String    |         | the data format, which should be `XML`                                                                          |
| config          | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg" |
| options         | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table           | String    |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)       |
| feature_class   | String    |         | the name of the root element, equivalent to UI option                                                           |
| feature_dataset | String    |         | the name used for each data element, equivalent to UI option                                                    |
| file            | String    |         | the absolute filepath to the export file, including extension e.g. "C:/Temp/Badger.xml"                         |

### Data Export for MDB (Jet / Microsoft Access Database)

```ruby
#odic_export_ex(format, config, options, table, destination, file)
```

Exports data to a Jet / Microsoft Access Database file.

**Parameters**

| Name        | Type(s)   | Default | Description                                                                                                     |
| ----------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format      | String    |         | the data format, which should be `MDB`                                                                          |
| config      | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg" |
| options     | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table       | String    |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)       |
| destination | String    |         | the destination table in the database                                                                           |
| file        | String    |         | the absolute filepath to the database, including extension e.g. "C:/Temp/Badger.mdb"                            |

### Data Export for SHP (ESRI Shapefile)

```ruby
#odic_export_ex(format, config, options, table, file)
```

Exports data to an ESRI Shapefile.

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `SHP`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)       |
| file    | String    |         | the absolute filepath to the export file, including extension e.g. "C:/Temp/Badger.shp"                         |

### Data Export for TAB (MapInfo TAB)

```ruby
#odic_export_ex(format, config, options, table, file)
```

Exports data to a MapInfo TAB file.

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `TAB`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)       |
| file    | String    |         | the absolute filepath to the export file, including extension e.g. "C:/Temp/Badger.tab"                         |

### Data Export for GDB (Personal GeoDatabase)

```ruby
#odic_export_ex(format, config, options, table, feature_class, feature_dataset, update, keyword, file)
```

Exports data to a GeoDatabase.

**Parameters**

| Name            | Type(s)     | Default | Description                                                                                                                                |
| --------------- | ----------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| format          | String      |         | the data format, which should be `CSV`                                                                                                     |
| config          | String      |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg"                            |
| options         | Hash, nil   |         | hash of options, or nil to use defaults                                                                                                    |
| table           | String      |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)                                  |
| feature_class   | String      |         | the name of the root element, equivalent to UI option                                                                                      |
| feature_dataset | String      |         | the name used for each data element, equivalent to UI option                                                                               |
| update          | Boolean     |         | if true the feature class must already exist                                                                                               |
| keyword         | String, nil |         | ArcSDE configuration keyword, `nil` for personal or File GeoDatabases, ignored for updates"                                                |
| file            | String      |         | the absolute filepath to the export file, including extension e.g. `.GDB` for personal / file GeoDatabases, or the connection name for SDE |

### Data Export for FILEGDB (File GeoDatabase)

```ruby
#odic_export_ex(format, config, options, table, feature_class, feature_dataset, update, keyword, file)
```

Exports data to a GeoDatabase.

**Parameters**

| Name            | Type(s)     | Default | Description                                                                                                                                |
| --------------- | ----------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| format          | String      |         | the data format, which should be `CSV`                                                                                                     |
| config          | String      |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg"                            |
| options         | Hash, nil   |         | hash of options, or nil to use defaults                                                                                                    |
| table           | String      |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)                                  |
| feature_class   | String      |         | the name of the root element, equivalent to UI option                                                                                      |
| feature_dataset | String      |         | the name used for each data element, equivalent to UI option                                                                               |
| update          | Boolean     |         | if true the feature class must already exist                                                                                               |
| keyword         | String, nil |         | ArcSDE configuration keyword, `nil` for personal or File GeoDatabases, ignored for updates"                                                |
| file            | String      |         | the absolute filepath to the export file, including extension e.g. `.GDB` for personal / file GeoDatabases, or the connection name for SDE |

### Data Export for ORACLE (Oracle Database)

```ruby
#odic_export_ex(format, config, options, table, destination, owner, update, username, password, connection_string)
```

Exports data to an Oracle database.

**Parameters**

| Name              | Type(s)   | Default | Description                                                                                                     |
| ----------------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format            | String    |         | the data format, which should be `CSV`                                                                          |
| config            | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg" |
| options           | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table             | String    |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)       |
| destination       | String    |         | the destination table name                                                                                      |
| owner             | String    |         | the owner of the destination table                                                                              |
| update            | Boolean   |         |                                                                                                                 |
| password          | String    |         |                                                                                                                 |
| connection_string | String    |         |                                                                                                                 |
| username          | String    |         |                                                                                                                 |

### Data Export for SQLSERVER (Microsoft SQL Server)

```ruby
#odic_export_ex(format, config, options, table, destination, server, instance, database, update, trusted, username, password)
```

Exports data to a Microsoft SQL Server database. Other SQL database types such as PostGIS are not supported.

**Parameters**

| Name        | Type(s)     | Default | Description                                                                                                     |
| ----------- | ----------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format      | String      |         | the data format, which should be `SQLSERVER`                                                                    |
| config      | String      |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ExportFields.cfg" |
| options     | Hash, nil   |         | hash of options, or nil to use defaults                                                                         |
| table       | String      |         | the table to export, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)       |
| destination | String      |         | the destination table in the SQL Server database                                                                |
| server      | String      |         | the server address, e.g. `localhost//SQLEXPRESS`                                                                |
| instance    | String      |         | the SQL server instance name, or nil                                                                            |
| database    | String      |         | the name of the database                                                                                        |
| update      | String      |         |                                                                                                                 |
| trusted     | Boolean     |         | use trusted connection / integrated security                                                                    |
| username    | String, nil |         | username, or nil if using a trusted connection                                                                  |
| password    | String, nil |         | password, or nil if using a trusted connection                                                                  |

## odic_import_ex

```ruby
#odic_import_ex(format, config, options, table, *args) ⇒ void
```

`EXCHANGE`, `UI`

Imports and updates network data using the Open Data Import Centre.

The supported formats are `CSV`, `TSV`, `XML`, `MDB`, `SHP`, `TAB`, `GDB`, `FILEGDB`, `ORACLE`, and `SQLSERVER`. The format used determines the number of additional arguments in the method, which are detailed below.

The options hash uses the following keys:

{::ICM}

| **Key**                        |  **Type**  | **Default** | **Notes**                                              |
| ------------------------------ | :--------: | :---------: | ------------------------------------------------------ |
| Allow Multiple Asset IDs       |  Boolean   |    false    |                                                        |
| Blob Merge                     |  Boolean   |    false    |                                                        |
| Callback Class                 | Ruby Class |     nil     | Class used for Ruby callback method                    |
| Default Value Flag             |   String   |     nil     | Flag used for fields set from the default value column |
| Delete Missing Objects         |  Boolean   |    false    |                                                        |
| Duplication Behaviour          |   String   |   'Merge'   | One of 'Overwrite', 'Merge', 'Ignore'                  |
| Error File                     |   String   |     nil     | Path of error file                                     |
| Group Name                     |   String   |     nil     | Asset networks only                                    |
| Group Type                     |   String   |     nil     | Asset networks only                                    |
| Image Folder                   |   String   |     nil     | Folder to import images from (asset networks only)     |
| Import Images                  |  Boolean   |    false    | Asset networks only                                    |
| Set Value Flag                 |   String   |     nil     | Flag used for fields set from data                     |
| Units Behaviour                |   String   |  'Native'   | One of 'Native', 'User', or 'Custom'                   |
| Update Based On Asset ID       |  Boolean   |    false    |                                                        |
| Update Links From Points       |  Boolean   |    false    |                                                        |
| Update Only                    |  Boolean   |    false    |                                                        |
| Use Network Naming Conventions |  Boolean   |    false    |                                                        |
| Don't Update Geometry          |  Boolean   |    false    |                                                        |

{::/ICM}

{::WSPRO}

| **Key**                        |   **Type**    | **Default** | **Notes**                                                                                                                                                                                               |
| ------------------------------ | :-----------: | :---------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Allow Multiple Asset IDs       |    Boolean    |    false    |                                                                                                                                                                                                         |
| Blob Merge                     |    Boolean    |    false    |                                                                                                                                                                                                         |
| Script File                    |    String     |     nil     | Path to .bas script                                                                                                                                                                                     |
| Default Value Flag             |    String     |     nil     | Flag used for fields set from the default value column                                                                                                                                                  |
| Delete Missing Objects         |    Boolean    |    false    |                                                                                                                                                                                                         |
| Duplication Behaviour          |    String     |   'Merge'   | One of 'Overwrite', 'Merge', 'Ignore'                                                                                                                                                                   |
| Error File                     |    String     |     nil     | Path of error file                                                                                                                                                                                      |
| Set Value Flag                 |    String     |     nil     | Flag used for fields set from data                                                                                                                                                                      |
| Units Behaviour                |    String     |  'Native'   | One of 'Native', 'User', or 'Custom'                                                                                                                                                                    |
| Update Based On Asset ID       |    Boolean    |    false    |                                                                                                                                                                                                         |
| Update Links From Points       |    Boolean    |    false    |                                                                                                                                                                                                         |
| Don't Update Geometry          |    Boolean    |    false    |                                                                                                                                                                                                         |
| Update Only                    |    Boolean    |    false    |                                                                                                                                                                                                         |
| Use Network Naming Conventions |    Boolean    |    false    |                                                                                                                                                                                                         |
| Network                        | WSOpenNetwork |     nil     | When importing to a Control network, this can be used in conjunction with `Update Based On Asset ID` to match records. This is useful when the primary key is not known in the source data, e.g. links. |

{::/WSPRO}

{::ICM}
### Data Import for CSV (Comma Separated Values)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from a Comma Separated Values file.

**Examples**

```ruby
network.odic_import_ex('CSV', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.csv')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `CSV`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)   <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.csv"  

{::/ICM}

{::WSPRO}

### Data Import for CSV (Comma Separated Values)
```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from a Comma Separated Values file.

**Examples**

```ruby
network.odic_import_ex('CSV', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.csv')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `CSV`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)  |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.csv"  

{::/WSPRO}

{::ICM}

### Data Import for TSV (Tab Separated Values)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from a Tab Separated Values file.

**Examples**

```ruby
network.odic_import_ex('TSV', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.tsv')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                      |
| ------- | --------- | ------- | ---------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `TSV`                                                                           |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg"  |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                          |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey) <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph     |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.csv" or "C:/Temp/Penguin.tsv" |

{::/ICM}

{::WSPRO}

### Data Import for TSV (Tab Separated Values)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from a Tab Separated Values file.

**Examples**

```ruby
network.odic_import_ex('TSV', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.tsv')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                      |
| ------- | --------- | ------- | ---------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `TSV`                                                                           |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg"  |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                          |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)      |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.csv" or "C:/Temp/Penguin.tsv" |

{::/WSPRO}

{::ICM}

### Data Import for XML (Extensible Markup Language)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from an XML (Extensible Markup Language) file.

**Examples**

```ruby
network.odic_import_ex('XML', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.xml')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `XML`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey) <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph    |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.xml"                         |

{::/ICM}

{::WSPRO}

### Data Import for XML (Extensible Markup Language)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from an XML (Extensible Markup Language) file.

**Examples**

```ruby
network.odic_import_ex('XML', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.xml')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `XML`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.xml"                         |

{::/WSPRO}

{::ICM}

### Data Import for MDB (Jet / Microsoft Access Database)

```ruby
#odic_import_ex(format, config, options, table, database, source) ⇒ void
```

Imports data from a Jet / Microsoft Access Database file.

**Examples**

```ruby
network.odic_import_ex('MDB', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyDatabase.mdb', 'MyNodes')
```

**Parameters**

| Name     | Type(s)   | Default | Description                                                                                                     |
| -------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format   | String    |         | the data format, which should be `MDB`                                                                          |
| config   | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options  | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table    | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| database | String    |         | the absolute filepath to the database   <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph                                                                       |
| source   | String    |         | a table in the database, or a stored SQL query in the database - a SQL expression cannot be used directly       |

{::/ICM}

{::WSPRO}

### Data Import for MDB (Jet / Microsoft Access Database)

```ruby
#odic_import_ex(format, config, options, table, database, source) ⇒ void
```

Imports data from a Jet / Microsoft Access Database file.

**Examples**

```ruby
network.odic_import_ex('MDB', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyDatabase.mdb', 'MyNodes')
```

**Parameters**

| Name     | Type(s)   | Default | Description                                                                                                     |
| -------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format   | String    |         | the data format, which should be `MDB`                                                                          |
| config   | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options  | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table    | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| database | String    |         | the absolute filepath to the database                                                                           |
| source   | String    |         | a table in the database, or a stored SQL query in the database - a SQL expression cannot be used directly       |

{::/WSPRO}

{::ICM}

### Data Import for SHP (ESRI Shapefile)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from an ESRI Shapefile.

**Examples**

```ruby
network.odic_import_ex('SHP', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.shp')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `SHP`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)  <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph   |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.shp"                         |

{::/ICM}

{::WSPRO}

### Data Import for SHP (ESRI Shapefile)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from an ESRI Shapefile.

**Examples**

```ruby
network.odic_import_ex('SHP', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.shp')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `SHP`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.shp"                         |

{::/WSPRO}

{::ICM}

### Data Import for TAB (MapInfo TAB)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from a MapInfo TAB file.

**Examples**

```ruby
network.odic_import_ex('TAB', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.tab')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `TAB`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey) <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph    |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.tab"                         |

{::/ICM}

{::WSPRO}

### Data Import for TAB (MapInfo TAB)

```ruby
#odic_import_ex(format, config, options, table, file) ⇒ void
```

Imports data from a MapInfo TAB file.

**Examples**

```ruby
network.odic_import_ex('TAB', 'C:/Badger/Config.cfg', nil, 'Node', 'C:/Badger/MyNodes.tab')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `TAB`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.tab"                         |

{::/WSPRO}

{::ICM}

### Data Import for GDB (Personal GeoDatabase)

```ruby
#odic_import_ex(format, config, options, table, feature, file) ⇒ void
```

Imports data from a GeoDatabase.

**Examples**

```ruby
network.odic_import_ex('GDB', 'C:/Badger/Config.cfg', nil, 'Node', 'GISNodes' 'C:/Badger/MyMap.gdb')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `XML`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)   <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph  |
| feature | String    |         | the feature class to import from                                                                                |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.gdb"                         |

{::/ICM}

{::WSPRO}

### Data Import for GDB (Personal GeoDatabase)

```ruby
#odic_import_ex(format, config, options, table, feature, file) ⇒ void
```

Imports data from a GeoDatabase.

**Examples**

```ruby
network.odic_import_ex('GDB', 'C:/Badger/Config.cfg', nil, 'Node', 'GISNodes' 'C:/Badger/MyMap.gdb')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `XML`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| feature | String    |         | the feature class to import from                                                                                |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.gdb"                         |

{::/WSPRO}

### Data Import for FILEGDB (File GeoDatabase)

```ruby
#odic_import_ex(format, config, options, table, feature, file) ⇒ void
```

Imports data from a GeoDatabase.

**Examples**

```ruby
network.odic_import_ex('GDB', 'C:/Badger/Config.cfg', nil, 'Node', 'GISNodes' 'C:/Badger/MyMap.gdb')
```

**Parameters**

| Name    | Type(s)   | Default | Description                                                                                                     |
| ------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format  | String    |         | the data format, which should be `XML`                                                                          |
| config  | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table   | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| feature | String    |         | the feature class to import from                                                                                |
| file    | String    |         | the absolute filepath to the import file, including extension e.g. "C:/Temp/Badger.gdb"                         |

{::ICM}

### Data Import for ORACLE (Oracle Database)

```ruby
#odic_import_ex(format, config, options, table, source, connection, owner, username, password) ⇒ void
```

Imports data from an Oracle database.

**Examples**

```ruby
network.odic_import_ex('ORACLE', 'C:/Badger/Config.cfg', nil, 'Node', 'MyNodes',
  'localhost/orcl', nil, 'username', 'badger1234')
```

**Parameters**

| Name       | Type(s)   | Default | Description                                                                                                     |
| ---------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format     | String    |         | the data format, which should be `XML`                                                                          |
| config     | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options    | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table      | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)   <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph  |
| source     | String    |         | the source table in the Oracle database                                                                         |
| connection | String    |         | the connection string, e.g. `//power/orcl`                                                                      |
| owner      | String    |         | the owner of the table being imported from                                                                      |
| username   | String    |         | username                                                                                                        |
| password   | String    |         | password                                                                                                        |

{::/ICM}

{::WSPRO}

### Data Import for ORACLE (Oracle Database)

```ruby
#odic_import_ex(format, config, options, table, source, connection, owner, username, password) ⇒ void
```

Imports data from an Oracle database.

**Examples**

```ruby
network.odic_import_ex('ORACLE', 'C:/Badger/Config.cfg', nil, 'Node', 'MyNodes',
  'localhost/orcl', nil, 'username', 'badger1234')
```

**Parameters**

| Name       | Type(s)   | Default | Description                                                                                                     |
| ---------- | --------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format     | String    |         | the data format, which should be `XML`                                                                          |
| config     | String    |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options    | Hash, nil |         | hash of options, or nil to use defaults                                                                         |
| table      | String    |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| source     | String    |         | the source table in the Oracle database                                                                         |
| connection | String    |         | the connection string, e.g. `//power/orcl`                                                                      |
| owner      | String    |         | the owner of the table being imported from                                                                      |
| username   | String    |         | username                                                                                                        |
| password   | String    |         | password                                                                                                        |

{::/WSPRO}

{::ICM}

### Data Import for SQLSERVER (Microsoft SQL Server)

```ruby
#odic_import_ex(format, config, options, table, source, server, instance, database, trusted, username, password) ⇒ void
```

Imports data from a Microsoft SQL Server database. Other SQL database types such as PostGIS are not supported.

**Examples**

```ruby
network.odic_import_ex('SQLSERVER', 'C:/Badger/Config.cfg', nil, 'Node', 'MyNodes',
  'localhost//SQLEXPRESS', nil, 'dbo.MyDatabase', nil, 'username', 'badger1234')
```

**Parameters**

| Name     | Type(s)     | Default | Description                                                                                                     |
| -------- | ----------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format   | String      |         | the data format, which should be `SQLSERVER`                                                                    |
| config   | String      |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options  | Hash, nil   |         | hash of options, or nil to use defaults                                                                         |
| table    | String      |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)  <br/>Note that when importing a RTK Hydrograph table, the destination table must be specifed as UnitHydrograph not RTKHydrograph   |
| source   | String      |         | the source table in the SQL Server database                                                                     |
| server   | String      |         | the server address, e.g. `localhost//SQLEXPRESS`                                                                |
| instance | String, nil |         | the SQL server instance name, or nil                                                                            |
| database | String      |         | the name of the database                                                                                        |
| trusted  | Boolean     |         | use trusted connection / integrated security                                                                    |
| username | String, nil |         | username, or nil if using a trusted connection                                                                  |
| password | String, nil |         | password, or nil if using a trusted connection                                                                  |

{::/ICM}

{::WSPRO}

### Data Import for SQLSERVER (Microsoft SQL Server)

```ruby
#odic_import_ex(format, config, options, table, source, where, order, server, instance, database, trusted, username, password) ⇒ void
```

Imports data from a Microsoft SQL Server database. Other SQL database types such as PostGIS are not supported.

**Examples**

```ruby
network.odic_import_ex('SQLSERVER', 'C:/Badger/Config.cfg', nil, 'Node', 'MyNodes', "[town] = 'mytown'", 'id',
  'localhost//SQLEXPRESS', nil, 'dbo.MyDatabase', nil, 'username', 'badger1234')
```

**Parameters**

| Name     | Type(s)     | Default | Description                                                                                                     |
| -------- | ----------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| format   | String      |         | the data format, which should be `SQLSERVER`                                                                    |
| config   | String      |         | the absolute filepath to the field config file exported from the user interface e.g. "C:/Temp/ImportFields.cfg" |
| options  | Hash, nil   |         | hash of options, or nil to use defaults                                                                         |
| table    | String      |         | the destination table, as displayed in the UI with any spaces removed (e.g. CCTV Survey becomes CCTVSurvey)     |
| source   | String      |         | the source table in the SQL Server database                                                                     |
| where    | String, nil |         | an optional WHERE clause to efficiently filter data, see below                                                  |
| order    | String, nil |         | an optional ORDER BY clause, which can be used to ensure structured array data is imported correctly            |
| server   | String      |         | the server address, e.g. `localhost//SQLEXPRESS`                                                                |
| instance | String, nil |         | the SQL server instance name, or nil                                                                            |
| database | String      |         | the name of the database                                                                                        |
| trusted  | Boolean     |         | use trusted connection / integrated security                                                                    |
| username | String, nil |         | username, or nil if using a trusted connection                                                                  |
| password | String, nil |         | password, or nil if using a trusted connection                                                                  |

The `where` parameter allows you to filter the SQL query that fetches data, which is more efficient than fetching all data and filtering it via VBScript. For example you can filter values by the contents of a field, a constant number or string, arithmetic and logical operators, null tests, etc.

{::/WSPRO}

## remove_local

```ruby
#remove_local ⇒ void
```

`EXCHANGE`, `UI`

Removes any local working copy of this network. This can be used to free space in the user/script's working directory.
