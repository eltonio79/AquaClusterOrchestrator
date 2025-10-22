{ALL}

# WSNumbatNetworkObject

[WSModelObject](./wsmodelobject.md) > [WSBaseNetworkObject](./wsbasenetworkobject.md) > WSNumbatNetworkObject

A network using merge version control.

Note: a network in this context is not the same as a 'network' in the user interface.

**Methods:**

{{toc}}

## branch

```ruby
#branch(commit_id, new_name) ⇒ WSModelObject
```

`EXCHANGE`, `UI`

Branches the network object, creating a new network object.

**Parameters**

| Name      | Type(s)       | Description                                  |
| --------- | ------------- | -------------------------------------------- |
| commit_id | Integer       | The branch is performed from this commit id. |
| new_name  | String        | The new network name.                        |
| Return    | WSModelObject |                                              |

## commit

```ruby
#commit(comment) ⇒ Integer
```

`EXCHANGE`, `UI`

Commits any changes to the network to the database. Returns the commit ID, or returns nil if there were no changes made and therefore no new commit.

```ruby
network.commit('This is the comment for my commit')
```

**Parameters**

| Name    | Type(s) | Description |
| ------- | ------- | ----------- |
| comment | String  |             |
| Return  | Integer |             |

## commit_reserve

```ruby
#commit_reserve(comment) ⇒ Integer
```

`EXCHANGE`, `UI`

Performs the same action as `commit`, but keeps the network reserved if it was already.

**Parameters**

| Name    | Type(s) | Description |
| ------- | ------- | ----------- |
| comment | String  |             |
| Return  | Integer |             |

## commits

```ruby
#commits ⇒ WSCommits
```

`EXCHANGE`, `UI`

Returns the commit history for the network.

Example of printing the number of commits:

```ruby
commits = network.commits
puts "There have been #{commits.length} commits to this network!"
```

Example of printing all comments from user 'Badger':

```ruby
network.commits.each do |commit|
  puts \"#{commit.commit_id}: #{commit.comment}\" if commit.user == 'Badger'
end
```

**Parameters**

| Name   | Type(s)   | Description |
| ------ | --------- | ----------- |
| Return | WSCommits |             |

{::ICM}

## csv_changes

```ruby
#csv_changes(commit_id_1, commit_id_2, file) ⇒ void
```

`EXCHANGE`

Outputs the differences between commit_id_1 and commit_id_2 of this network to the specified CSV file. The CSV file output is the same as the 'compare network' tool in the user interface, and can be used to apply the changes to another network via the 'Import/Update from CSV files' function.

**Parameters**

| Name        | Type(s) | Description                                |
| ----------- | ------- | ------------------------------------------ |
| commit_id_1 | Integer |                                            |
| commit_id_2 | Integer |                                            |
| file        | String  | Path to the csv file, including extension. |

{::/ICM}

## current_commit_id

```ruby
#current_commit_id ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the commit ID of the local copy of the network. This may not be the most recent commit ID on the server, which is returned by `#latest_commit_id`.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

{::ICM}

## gis_export

```ruby
#gis_export(format, options, destination) ⇒ void
```

`EXCHANGE`

Exports the network data to a GIS format.

The options hash contains the following keys. If the `options` parameter is nil or where the provided hash is missing a key, the default behavior applies.

| Key                    |   Data Type   | Description                                                                                                                                                      |
| ---------------------- | :-----------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ExportFlags            |    Boolean    | If `true` field flags are exported along with the data - default is `true`                                                                                       |
| Feature Dataset        |    String     | Only relevant for GeoDatabases - the name of the feature dataset, the default is an empty string                                                                 |
| SkipEmptyTables        |    Boolean    | If `true`, will skip empty tables - default is `false`                                                                                                           |
| Tables                 | Array\<String> | Table names which can be returned by the `#list_gis_export_tables` method, does not allow duplicates or unrecognized tables - by default, will export all tables |
| UseArcGISCompatability |    Boolean    | Default is `false`                                                                                                                                               |

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name        | Type(s)   | Description                                                                                                                            |
| ----------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| format      | String    | Either `shp` (esri shapefile), `tab` (mapinfo tab), `mif` (mapinfo mif), or `gdb` (esri geodatabase).                                  |
| options     | Hash, nil | See hash options in method description.                                                                                                |
| destination | String    | The folder for the files to be exported, except for a geodatabase, where it is the name of the geodatabase file with `.gdb` extension. |

{::/ICM}

## latest_commit_id

```ruby
#latest_commit_id ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the latest commit ID for the network from the server. This may not be the same commit ID as the local copy, which is returned by `#current_commit_id`.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

{::ICM}

## list_gis_export_tables

```ruby
#list_gis_export_tables ⇒ Array<String>
```

`EXCHANGE`

Returns the tables that will be exported using the [#gis_export](#gis_export) method.

Note: This method previously included capitalization, we recommend using the new lower case method name.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | Array\<String> |             |

{::/ICM}

## open

```ruby
#open ⇒ WSOpenNetwork
```

`EXCHANGE`

Opens the latest version of the network.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | WSOpenNetwork |             |

## open_version

```ruby
#open_version(commit_id) ⇒ WSOpenNetwork
```

`EXCHANGE`, `UI`

Opens a specific version of the network, from it's commit ID.

**Parameters**

| Name   | Type(s)       | Description |
| ------ | ------------- | ----------- |
| Return | WSOpenNetwork |             |

## reserve

```ruby
#reserve ⇒ void
```

`EXCHANGE`, `UI`

Reserves the network so no-one else can edit it, and also updates the local copy to the latest version.

## revert

```ruby
#revert ⇒ void
```

`EXCHANGE`, `UI`

Reverts any changes to the network that have not yet been committed. This does not guarantee that the network is up to date, only that any changes made to the local copy have been abandoned.

{::ICM}

## select_changes

```ruby
#select_changes(commit_id) ⇒ void
```

`EXCHANGE`

Select all objects added or changed between the provided commit ID, and the current network.

Deleted objects cannot be selected. The network must have no outstanding changes, or an exception will be raised.

{::/ICM}

{::ICM}

## select_clear

```ruby
#select_clear ⇒ void
```

`EXCHANGE`

Deselects all objects in the network.

{::/ICM}

{::ICM}

## select_count

```ruby
#select_count ⇒ Integer
```

`EXCHANGE`

Returns the number of selected objects in the network.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Integer |             |

{::/ICM}

{::ICM}

## select_sql

```ruby
#select_sql(table, query) ⇒ Integer
```

`EXCHANGE`

Runs a SQL select query. A SQL query can further qualify the table name in the query, or work with multiple tables.

The SQL query can include multiple clauses, including saving results to a file, but cannot use any of the options that open results or prompt grids.

Example of selecting all nodes in the network, above 40m elevation:

```ruby
count = network.select_sql('_nodes', 'z > 40')
puts format("There are %i nodes above 40m in this network!", count)
```

Example of selecting node ID's into a file:

```ruby
network.select_sql('hw_node', "SELECT oid INTO FILE 'C:\Export\Distinct.csv'")
```

**Parameters**

| Name   | Type(s) | Description                                                                                |
| ------ | ------- | ------------------------------------------------------------------------------------------ |
| table  | String  | The table name, `_nodes` or `_links` are equivalent to 'all nodes' and 'all links' in sql. |
| query  | String  | The sql query.                                                                             |
| Return | Integer | The number of objects selected in the last clause, or 0.                                   |

{::/ICM}

## uncommitted_changes?

```ruby
#uncommitted_changes? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns if there are uncommitted changes to the network.

**Parameters**

| Name   | Type(s) | Description |
| ------ | ------- | ----------- |
| Return | Boolean |             |

## unreserve

```ruby
#reserve ⇒ void
```

`EXCHANGE`, `UI`

Cancels any reservation of the network.

## update

```ruby
#update ⇒ Boolean
```

`EXCHANGE`, `UI`

Updates the local copy of the network to the latest version from the server. Not relevant for Standalone databases.

**Parameters**

| Name   | Type(s) | Description                                                |
| ------ | ------- | ---------------------------------------------------------- |
| Return | Boolean | True if this was successful, false if there are conflicts. |

{::ICM}

## user_field_names

```ruby
#user_field_names(file, string) ⇒ void
```

`EXCHANGE`

Exports a CSV file containing the user field names for all object types in the network, which will include any network or database customisations.

The CSV file has no header. The first column is the provided string, the second column is the internal user field table name, and the third column is the user field name as shown in the user interface including customisations.

```ruby
network.user_field_names('C:/Temp/Badger.csv', 'x')
```

Produces:

```csv
x, user_text_1, Badger
x, user_text_2, Penguin
```

**Parameters**

| Name   | Type(s) | Description                                                          |
| ------ | ------- | -------------------------------------------------------------------- |
| file   | String  | The file to export, including extension (`.csv`).                    |
| string | String  | An arbitrary string value, which will be output as the first column. |

{::/ICM}
