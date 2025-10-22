{ALL}

# WSTableInfo

Metadata for a network table. This only contains information about the table structure, not the current values for any particular object.

**Methods:**

{{toc}}

## description

```ruby
#description ⇒ String
```

`EXCHANGE`, `UI`

Returns the description of the table.

## fields

```ruby
#fields ⇒ Array<WSFieldInfo>
```

`EXCHANGE`, `UI`

Returns the fields of this table, as an array of [WSFieldInfo](wsfieldinfo.md) objects. Flags are treated as separate fields.

## name

```ruby
#name ⇒ String
```

`EXCHANGE`, `UI`

Returns the internal name of the table.

## results_fields

```ruby
#results_fields ⇒ Array<WSFieldInfo>
```

`EXCHANGE`, `UI`

Returns the results fields of this table, as an array of [WSFieldInfo](wsfieldinfo.md) objects.

This method is only available when the [WSTableInfo](wstableinfo.md) object was accessed from a network with simulation results available. The fields returned will reflect the results in that simulation, including the values of their `#has_time_varying_results?` and `#has_max_results?` methods. This can vary considerably depending on the type of simulation, run configuration, results selector, etc.

## tableinfo_json

```ruby
#tableinfo_json ⇒ String
```

`EXCHANGE`, `UI`

Returns the table information as a JSON string.
