{WSPRO}

# WSLiveDataConfigNumbat

[WSModelObject](./wsmodelobject.md) > [WSBaseNetworkObject](./wsbasenetworkobject.md) > [WSNumbatNetworkObject](./wsnumbatnetworkobject.md) > WSLiveDataConfigNumbat

A Live Data Configuration model object using merge version control.

**Methods:**

{{toc}}

## get_live_data

```ruby
#get_live_data(start, end, folder_name) ⇒ void
```

`EXCHANGE`, `UI`

Retrieves live data values for all feeds in the live data configuration, and writes them to a CSV file per feed.

**Parameters**

| Name  | Type(s)  | Description           |
| ----- | -------- | --------------------- |
| start | DateTime | Start date and time   |
| end   | DateTime | End date and time     |
| folder_name	  | String   | Path to folder to write CSV files to          |

## get_live_data_values

```ruby
#get_live_data_values(feed, start, end) ⇒ Array<Array>
```

`EXCHANGE`, `UI`

Retrieves the values from a live data feed. The values are returned as an array of arrays, where the inner array's first index is the date (as a Ruby `DateTime`), and the second index is the value:

```ruby
values = [
  ["2024/01/01 00:00", 30.00],
  ["2024/01/01 00:15", 32.00],
  ["2024/01/01 00:30", 28.00]
]
```

To retrieve the data:

```ruby
require 'date'

database = WSApplication.open()
ldc = database.model_object_from_type_and_id('Wesnet Live Data', 165)
live_data = ldc.get_live_data_values('composite', DateTime.new(2022,12,16), DateTime.new(2022,12,17))
```

Display method 1:

```ruby
live_data.each do |(date, value)|
  puts format("%s - %0.2f", date, value)
end
```

Display method 2:

```ruby
live_data.each do |(date, value)|
  puts "#{date} - #{value}"
end
```

**Parameters**

| Name  | Type(s)  | Description           |
| ----- | -------- | --------------------- |
| feed  | String   | The feed id.          |
| start | DateTime | The start time range. |
| end   | DateTime | The end time range.   |
