{ICM}

# WSOpenTSD

An open TSD object, allowing access to the timeseries data, similar to opening the TSD as a grid in the UI.

Dates and times in TSD are handled using the DateTime class provided by the Ruby standard library, if it is defined in the script. If DateTime is not available, then the built-in Time class is used. Note that DateTime is deprecated in modern Ruby.

{{toc}}

## TSD Hashes

The following TSD objects are implemented as hashes of their properties. Properties that must be set by the user when creating a new object are marked with a *. Properties that are set by the software, and cannot be updated, are marked with a +. Boolean, integer and string values default to false, 0 and '' respectively and are not included in the returned hash if they have a default value. Properties that are omitted when updating an existing object will retain their existing values after the update.

### Data Source

The data source hash contains the following properties:

| Key                   | Type    | Default | Description                                                                                            |
| --------------------- | ------- | ------- | ------------------------------------------------------------------------------------------------------ |
| +dataSourceId         | Integer |         | The data source ID. Only present if there is an ID (i.e. the data source has been saved to the database). |
| +index                | Integer |         | The index of the data source. Only present if there is no ID (i.e. the data source has not yet been saved to the database). |
| *streamName           | String  |         | The data source name |
| filename              | String  |         | Path to the telemetry database or folder |
| timeZone              | String  |         | Time zone of the data |
| +lastTimeSeriesUpdate | Time    |         | UTC time that the data source was last updated |
| autoUpdateEnabled     | Boolean |         | Not used in InfoWorks ICM |
| autoUpdateStartAt     | Integer |         | Not used in InfoWorks ICM |
| autoUpdateInterval    | Integer |         | Not used in InfoWorks ICM |
| autoUpdateTriggerFile | String  |         | Not used in InfoWorks ICM |
| script                | String  |         | Absolute path and name of the script file, plus any script parameters, which will be run at the start of the data update process. |
| scriptTimeout         | Integer |         | Interval of time after which the script is deemed to have failed (s) |
| +lastModified         | Time    |         | Time that the data source was last modified |
| srcGeomMetadata       | String  |         | (Spatial TSD only) |
| fileCount             | Integer |         | (Spatial TSD only) |
| projection            | String  |         | (Spatial TSD only) |
| areaOfInterest        | Array   |         | (Spatial TSD only) Array of four Floats |
| logonType             | Integer |         | 0 = trusted, 1 = username/password (Scalar TSD only) |
| username              | String  |         | Username for connecting to telemetry (Scalar TSD only) |
| password              | String  |         | Password for connecting to telemetry (Scalar TSD only) |
| server                | String  |         | Name of the server on which the telemetry database is stored. (Scalar TSD only) |
| database              | String  |         | Telemetry database, data server or URL (Scalar TSD only) |
| provider              | Integer |         | Database type (Scalar TSD only) <br> -1 = Unknown <br> 0 = JET <br> 1 = Oracle <br> 2 = SQL Server 7 <br> 3 = SQL Server <br> 4 = ODBC <br> 5 = PI <br> 6 = Simple CSV <br> 7 = SOPHIE (Pre) <br> 8 = SANDRE (XMO) <br> 9 = iHistorian <br> 10 = ClearSCADA <br> 11 = SQL Server (ODBC) <br> 12 = JET (ACE) <br> 13 = SCADAWatch <br> 14 = PI WebAPI <br> 15 = EA REST API <br> 16 = ADS Rest <br> 17 = Info360.com <br> 18 = Generic REST |
| netServiceName        | String  |         | Net service name (Scalar TSD only) |
| creationUser          | String  |         | Creation user (Scalar TSD only) |
| connectionString      | String  |         | Connection string (Scalar TSD only) |
| commandTimeout        | Integer |         | Command timeout (Scalar TSD only) |

### Data Stream

The data stream hash contains the following properties:

| Key                | Type    | Default | Description                                                                                         |
| ------------------ | ------- | ------- | ----------------------------------------------------------------------------------------------------|
| +streamId          | Integer |         | The data stream ID. Only present if there is an ID (i.e. the data stream has been saved to the database). |
| +index             | Integer |         | The index of the stream. Only present if there is no ID  (i.e. the data stream has not yet been saved to the database). |
| *streamType        | Integer |         | 0 = observed, 1 = forecast, 2 = derived, 3 = stream type count. Cannot be changed after the object is created. |
| *streamName        | String  |         | The stream name |
| +versionId         | Integer |         | Version ID |
| dataInterval       | Float   |         | Data interval |
| +latestUpdate      | Time    |         | The time the stream was last updated |
| +latestData        | Time    |         | The time of the most recent data |
| exFactor           | Float   |         | Value factor |
| exTimeOffset       | Float   |         | Value offset |
| +isRefd            | Boolean |         | Stream has been used in a simulation |
| +lastModified      | Time    |         | The time the stream was last modified |
| +recordCount       | Integer |         | The number of entries on the stream |
| units              | String  |         | (Scalar TSD only) Unit code for the physical quantity in the stream |
| exUpdateDisabled   | Boolean |         | External update disabled (Scalar TSD only) |
| exDataSourceId     | Integer |         | External data source (Scalar TSD only) |
| exUnits            | String  |         | Units type (Scalar TSD only) |
| exOffset           | Float   |         | Value offset (Scalar TSD only) |
| exMinThreshold     | Float   |         | Min. threshold (Scalar TSD only) |
| exMaxThreshold     | Float   |         | Max. threshold (Scalar TSD only) |
| exTable            | String  |         | Name of the table in the telemetry database which contains the live data feed (Scalar TSD only) |
| exDataColumn       | String  |         | Data column (Scalar TSD only) |
| exTimeColumn       | String  |         | Time column (Scalar TSD only) |
| exOriginTimeColumn | String  |         | Origin time column (Scalar TSD only) |
| exUserField1       | String  |         | User field 1 (Scalar TSD only) |
| exUserVal1         | String  |         | User value 1 (Scalar TSD only) |
| exUserField2       | String  |         | User field 2 (Scalar TSD only) |
| exUserVal2         | String  |         | User value 2 (Scalar TSD only) |
| exUserField3       | String  |         | User field 3 (Scalar TSD only) |
| exUserVal3         | String  |         | User value 3 (Scalar TSD only) |
| x                  | Float   |         | (Scalar TSD only) |
| y                  | Float   |         | (Scalar TSD only) |
| lookupId           | Integer |         | ID of lookup that is used to transform data imported to the stream (Scalar TSD only) |
| tagName            | String  |         | Tag name (Scalar TSD only) |
| description        | String  |         | Description (Scalar TSD only) |

### Data Value
Time series data values are hashes containing the following properties. Note that existing properties are not preserved when updating a data value.

| Key                | Type           | Default | Description                                                                                         |
| ------------------ | -------------- | ------- | ---------------------------------------|
| *t                  | Time          |         | Timestamp of the value or of the forecast origin (for data that is a series of forecast origins) |
| +tOrigin            | Time          |         | (Forecast value only) timestamp of the origin of this forecast value
| exclude            | Boolean        |         | Value is not to be used in simulation |
| readonly           | Boolean        |         | Value is not to be updated by an automated update (not used in InfoWorks ICM) |
| geomKey            | String         |         | Spatial TSD only - uniquely identifies the geometry of the spatial data |
| flag               | String         |         | Flag |
| value              | Double         |         | Value (Scalar TSD only). Not present if this is a forecast origin. May be missing (a null value). |
| values             | Array<Double>  |         | Array of values (Spatial TSD only). May be missing (a null value). |

### Lookup
Live data lookups are hashes containing the following properties.

| Key                | Type                 | Default | Description                                              |
| ------------------ | -------------------- | ------- | ---------------------------------------------------------|
| +lookupId          | Integer              |         | The lookup ID. Only present if there is an ID (i.e. the lookup has been saved to the database).           |
| +index             | Integer              |         | The index of the lookup. Only present if there is no ID (i.e. the lookup has not yet been saved to the database). |
| *lookupName        | String               |         | The lookup name                                          |
| +lastModified      | Time                 |         | The time the lookup was last modified                    |
| map                | Hash<String, String> |         | The lookup mapping |

### User Edit
User edits are hashes containing the following properties.

| Key                | Type    | Default | Description               |
| ------------------ | ------- | ------- | --------------------------|
| +userEditId        | Integer |         | The user edit ID          |
| *userEditName      | String  |         | The name of the user edit |
| +applied           | Boolean |         | Whether the user edit has been permanently applied to the stream |
| shared             | Boolean |         | Set if the user edit is available for use by other users (always true in InfoWorks ICM) |
| +locked            | Boolean |         | Set if the user edit has been used in a simulation |
| +userName          | String  |         | Name of the user who created the user edit |
| comment            | String  |         | Description or other comment on the user edit |
| *userEditStream    | String  |         | ID of the data stream to which the edit relates. Cannot be changed. |

### Geometry
A geometry (Spatial TSD only) is a hash containing parameters and point coordinates relating to the geometry of spatial data. It can be copied, but is not intended for external construction or manipulation.

**Methods:**

## data_sources_count

```ruby
#data_sources_count(type) ⇒ Integer
```

`EXCHANGE`

Returns the number of data sources in the TSD.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Return | Integer | Number of data sources in the TSD                  |

## data_source_by_id

```ruby
#data_source_by_id(ID) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the data source with the specified ID.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| ID     | Integer | ID of the data source to be returned               |
| Return | Hash    | The data source                                    |

## data_source_by_index

```ruby
#data_source_by_index(index) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the data source with the specified index.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| index  | Integer | Index of the data source to be returned            |
| Return | Hash    | The data source                                    |

## data_source_by_name

```ruby
#data_source_by_name(name) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the data source with the specified name.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Name   | String  | Name of the data source to be returned             |
| Return | Hash    | The data source                                    |

## data_source_delete

```ruby
#data_source_delete(ID) ⇒ void
```

`EXCHANGE`

Deletes the data source with the specified ID.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| ID     | Integer | ID of the data source to be deleted                |

## data_source_new

```ruby
#data_source_new(ID) ⇒ Hash<String, Any>
```

`EXCHANGE`

Creates a new data source with the specified name.

An exception is thrown if the TSD is a spatial TSD and already has a data source, or if the TSD is a sclar TSD and a data source with the supplied name already exists.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Name   | String  | Name for the new data source                       |
| Return | Hash    | The data source                                    |

## data_source_update

```ruby
#data_source_update(Source) ⇒ Hash<String, Any>
```

`EXCHANGE`

Finds the data source with the ID (or index if there is no ID) supplied in the Source hash, and updates it with the properties of the Source.

An exception is thrown if the name supplied in the hash is the same as the name of a different, existing data source.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Source | Hash    | The new properties of the data data source         |
| Return | Hash    | The updated data data source                       |

## forecast_data_add

```ruby
#forecast_data_add(ID, origin, flag, data, comment) ⇒ void
```

`EXCHANGE`

Adds forecast data to the specified data stream. The data should be passed in as an array of Data Value hashes (note that tOrigin must not be set in these hashes).

**Parameters**

| Name   | Type(s)       | Description                                        |
| ------ | ------------- | -------------------------------------------------- |
| ID     | Integer       | ID of the data stream                              |
| origin | Time          | Forecast origin of the data                        |
| flag   | String        | Flag to be assigned to all the added data values   |
| data   | Array<Data>   | Array of data values to be added                   |

## forecast_data_get

```ruby
#forecast_data_get(ID, origin) ⇒ Array<String, Any>
```

`EXCHANGE`

Gets forecast data from the specified data stream as an array of Data Value hashes.

**Parameters**

| Name   | Type(s)       | Description                                        |
| ------ | ------------- | -------------------------------------------------- |
| ID     | Integer       | ID of the data stream                              |
| origin | Time          | Forecast origin of the data                        |
| Return | Array<Data>   | Forecast data values                               |

## forecast_origins_get

```ruby
#forecast_origins_get(ID, from, to, options) ⇒ Array<String, Any>
```

`EXCHANGE`

Gets forecast origins in the given period from the specified data stream.

The options hash contains the following keys:

| Key           | Type           | Default | Description                            |
| ------------- | -------------- | ------- | ---------------------------------------|
| inclusive     | Boolean        | True    | Whether to include the from and to time points in the returned values, if present  |
| limit         | Integer        | 0       | Limit on number of values to be returned (0 for no limit) |
| versionId     | Integer        | 0       | TSD version for which results are to be returned (0 for latest) |

**Parameters**

| Name    | Type(s)       | Description                                        |
| ------- | ------------- | -------------------------------------------------- |
| ID      | Integer       | ID of the data stream                              |
| from    | Time/String   | From time (or string 'min' for minimum possible time) |
| to      | Time/String   | From time (or string 'max' for maximum possible time) |
| options | Hash          | Hash of options (see above)                       |
| Return  | Array<Data Value>   | Forecast origin data   |

## geometry_get

```ruby
#geometry_get(key) ⇒ Hash
```

`EXCHANGE`

Gets [#Geometry](Geometry) as a hash.

**Parameters**

| Name               | Type(s)        | Description                            |
| ------------------ | -------------- | ---------------------------------------|
| key                | String         |                                        |
| Return             | Hash           | Geometry hash                          |

## geometry_set

```ruby
#geometry_set(key, geometry) ⇒ void
```

`EXCHANGE`

Sets geometry from a geometry hash.

| Name               | Type(s)        | Description                            |
| ------------------ | -------------- | ---------------------------------------|
| key                | String         |                                        |
| geometry           | Hash           | Geometry hash                          |

## lookups_count

```ruby
#lookups_count() ⇒ Integer
```

`EXCHANGE`

Returns the number of lookups in the TSD.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Return | Integer | Number of lookups in the TSD                       |

## lookup_by_id

```ruby
#lookup_by_id(id) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the lookup specified by the ID.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| ID     | Integer | ID of the lookup                                   |
| Return | Hash    | Lookup                                             |

## lookup_by_index

```ruby
#lookup_by_index(index) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the lookup with the specified index.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| index  | Integer | Index of the lookup to be returned                 |
| Return | Hash    | The lookup                                         |

## lookup_by_name

```ruby
#lookup_by_name(name) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the lookup with the specified name.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Name   | String  | Name of the lookup to be returned                  |
| Return | Hash    | The lookup                                         |

## lookup_delete

```ruby
#lookup(ID) ⇒ void
```

`EXCHANGE`

Deletes the lookup with the specified ID.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| ID     | Integer | ID of the lookup to be deleted                     |

## lookup_new

```ruby
#lookup_new(ID) ⇒ Hash<String, Any>
```

`EXCHANGE`

Creates a new lookup with the specified name.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Name   | String  | Name for the new lookup                            |
| Return | Hash    | The lookup                                         |

## lookup_update

```ruby
#lookup_update(Source) ⇒ Hash<String, Any>
```

`EXCHANGE`

Finds the lookup with the ID (or index if there is no ID) supplied in the Source hash, and updates it with the properties of the Source.

An exception is thrown if the name supplied in the hash is the same as the name of a different, existing lookup

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Source | Hash    | The new properties of the lookup                   |
| Return | Hash    | The updated lookup                                 |

## streams_count

```ruby
#streams_count(type) ⇒ Integer
```

`EXCHANGE`

Returns the number of data streams of the given type in the TSD.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| type   | Integer | 0 = observed streams, 1 = forecast streams         |
| Return | Integer | Number of streams                                  |

## streams_load

```ruby
#streams_load(version) ⇒ void
```

`EXCHANGE`

Loads the TSD at the specified version from the database. This is required before accessing or editing the data. A version of 0 indicates that the current version should be loaded.

**Parameters**

| Name    | Type(s) | Description |
| ------- | ------- | ----------- |
| version | Integer | Database version, or 0 for latest |

## streams_save

```ruby
#streams_save(comment) ⇒ void
```

`EXCHANGE`

Saves the updated data streams, sources and lookups to the database. 

**Parameters**

| Name    | Type(s) | Description       |
| ------- | ------- | ----------------- |
| comment | String  | Comment to attach |

## stream_by_id

```ruby
#stream_by_id(id) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the properties of the data stream with the given ID as a hash.

**Parameters**

| Name    | Type(s) | Description                |
| ------- | ------- | -------------------------- |
| id      | Integer |                            |
| Return  | Hash    | The data stream            |

## stream_by_index

```ruby
#stream_by_index(index) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the data stream with the specified index.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| index  | Integer | Index of the data stream to be returned            |
| Return | Hash    | The data stream                                    |

## stream_by_name

```ruby
#stream_by_name(name) ⇒ Hash<String, Any>
```

`EXCHANGE`

Returns the data stream with the specified name.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Name   | String  | Name of the data stream to be returned             |
| Return | Hash    | The data stream                                    |

## stream_delete

```ruby
#stream(ID) ⇒ void
```

`EXCHANGE`

Deletes the data stream with the specified ID.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| ID     | Integer | ID of the data stream to be deleted                |

## stream_new

```ruby
#stream_new(ID) ⇒ Hash<String, Any>
```

`EXCHANGE`

Creates a new data stream with the specified name.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Name   | String  | Name for the new data stream                       |
| Return | Hash    | Data stream                        |

## stream_update

```ruby
#stream_update(Source) ⇒ Hash<String, Any>
```

`EXCHANGE`

Finds the data stream with the ID (or index if there is no ID) supplied in the Source hash, and updates it with the properties of the Source.

An exception is thrown if the name supplied in the hash is the same as the name of a different, existing data source.

**Parameters**

| Name   | Type(s) | Description                                        |
| ------ | ------- | -------------------------------------------------- |
| Source | Hash    | The new properties of the data stream              |
| Return | Hash    | The updated data stream                            |

## time_series_data_add

```ruby
#time_series_data_add(ID, data, comment) ⇒ void
```

`EXCHANGE`

Adds time series data to the specified data stream. The data should be passed in as an array of Data value hashes.

**Parameters**

| Name    | Type(s)           | Description                                        |
| ------- | ----------------- | -------------------------------------------------- |
| ID      | Integer           | ID of the data stream                              |
| data    | Array<Data Value> | Data calues to be added                            |
| comment | String            | Comment to be associated with the data             |

## time_series_data_get

```ruby
#time_series_data_get(ID, from, to, options) ⇒ Array<Data>
```

`EXCHANGE`

Gets time series data from the specified data stream as an array of Data value hashes. For forecast data, the returned series may contain values from multiple forecasts (different time origins) but only one value is returned for any given timestamp and this is the value that has the latest time origin (i.e. the most recent forecast for that time). The range option defaults to "between" and has the following choices:

| inside  | data at times that are inside from and to (i.e. not including the from and to times) |
| between | data at times between from and to (including those time points, if they exist) |
| outside | data at times between from and to, plus the time points immediately before the start and after the end of the specified range, if they exist |

The options hash has the following keys:

| Key                | Type            | Default | Description                                                                             |
| ------------------ | --------------- | ------- | ---------------------------------------|
| range              | String,         |         | Optional. "between", "inside", "outside" or nil  |
| limit              | Integer         | 0       | Limit on the number of values to be returned (0 for no limit) |
| versionId          | Integer         | 0       | Version of the TSD from which the values are to be returned (0 for latest) |
| userEditIds        | Array<Integer>  |         | Optional. User edits that should be applied to the returned values. |
| futureExclude      | Time            |         | Optional. Exclude data values that are from the nominal future of the specified time (i.e. observed data with a timestamp after this time and forecast data with an origin timestamp after this time) |
| ref                | String          |         | Optional. Value to be set as a reference for a simulation in which this data is to be used. If set, has the effect of setting the refd property of the stream to true |

**Parameters**

| Name    | Type(s)       | Description                                           |
| ------- | ------------- | ----------------------------------------------------- |
| ID      | Integer       | ID of the data stream                                 |
| from    | Time/String   | From time (or string 'min' for minimum possible time) |
| to      | Time/String   | From time (or string 'max' for maximum possible time) |
| options | Hash          | Optional hash of options. See description above       |
| Return  | Array<Data>   | Data values                                           |

## user_edit_data_get

```ruby
#user_edit_data_get(ID, from, to, options) ⇒ Array<Data>
```

`EXCHANGE`

Gets data from the specified user edit as an array of Data value hashes.

**Parameters**

| Name   | Type(s)       | Description                                           |
| ------ | ------------- | ----------------------------------------------------- |
| ID     | Integer       | ID of the user edit                                   |
| from    | Time/String  | From time (or string 'min' for minimum possible time) |
| to      | Time/String  | From time (or string 'max' for maximum possible time) |
| Return | Array<Data>   | User edit data values                                 |

## user_edit_data_update

```ruby
#user_edit_data_update(ID, from, to, options) ⇒ void
```

`EXCHANGE`

Adds data to or removes data from the specified user edit.

**Parameters**

| Name   | Type(s)           | Description                                        |
| ------ | ----------------- | -------------------------------------------------- |
| ID     | Integer           | ID of the user edit                                |
| add    | Array<Data Value> | Array of data values to be added                   |
| remove | Array<Time>       | Array of timestamps of data to be removed          |

## user_edits

```ruby
#user_edits(ID, from, to) ⇒ Array<Hash>
```

`EXCHANGE`

Gets the current user's user edits from the specified data stream as an array of user edit hashes, sorted by name.

**Parameters**

| Name   | Type(s)       | Description                                           |
| ------ | ------------- | ----------------------------------------------------- |
| ID     | Integer       | ID of the user edit                                   |
| from   | Time/String   | From time (or string 'min' for minimum possible time) |
| to     | Time/String   | From time (or string 'max' for maximum possible time) |
| Return | Array<Hash>   | Array of user edits                                   |

## user_edit_apply

```ruby
#user_edit_apply(ID, readonly) ⇒ void
```

`EXCHANGE`

Applies the specified user edit to the data stream that it is associated with.

**Parameters**

| Name      | Type(s)       | Description                                        |
| --------- | ------------- | -------------------------------------------------- |
| ID        | Integer       | ID of the user edit                              |
| readonly  | Boolean       | Whether to mark the edited data as readonly       |

## user_edit_by_id

```ruby
#user_edit_by_id(ID) ⇒ Hash
```

`EXCHANGE`

Retrieves the specified user edit as a user edit hash.

**Parameters**

| Name      | Type(s)       | Description                                        |
| --------- | ------------- | -------------------------------------------------- |
| ID        | Integer       | ID of the user edit                                |
| Return    | Hash          | The user edit                                      |

## user_edit_by_name

```ruby
#user_edit_by_name(Name) ⇒ Hash
```

`EXCHANGE`

Retrieves the specified user edit as a user edit hash.

**Parameters**

| Name      | Type(s)       | Description                                        |
| --------- | ------------- | -------------------------------------------------- |
| Name      | String        | Name of the user edit                              |
| Return    | Hash          | The user edit                                      |

## user_edit_delete

```ruby
#user_edit_delete(ID) ⇒ void
```

`EXCHANGE`

Deletes the specified user edit.

**Parameters**

| Name      | Type(s)       | Description                                        |
| --------- | ------------- | -------------------------------------------------- |
| ID        | Integer       | ID of the user edit                                |

## user_edit_new

```ruby
#user_edit_new(Name, StreamID, shared) ⇒ void
```

`EXCHANGE`

Creates a new user edit. Throws an exception if an edit with the specified name already exists.

**Parameters**

| Name      | Type(s)       | Description                                        |
| --------- | ------------- | -------------------------------------------------- |
| Name      | String        | Name for the the user edit                              |
| SrreamID  | Integer       | ID of the data stream that the edit is to be associated with                              |
| shared    | Boolean       | Whether the user edit should be shared for use by other users (should be set to true to be consistent with normal InfoWorks ICM usage) |

## user_edit_update

```ruby
#user_edit_update(Edit) ⇒ Hash
```

`EXCHANGE`

Updates the user edit with the name, comment and shared properties from the hash. Throws an exception if the ID is missing or invalid or doesn't match en existing edit or if a different edit has the same name.

**Parameters**

| Name      | Type(s)    | Description                                        |
| --------- | ---------- | -------------------------------------------------- |
| Edit      | Hash       | The user edit hash                                 |
| Return    | Hash       | The updated user edit                              |

