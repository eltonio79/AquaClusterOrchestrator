{ALL}

# Dates and Times

The `DateTime` class provided by the Ruby standard library is used to represent most dates and times. If you expect to use any methods that get or set dates, you will need to require the date module at the top of your script file.

```ruby
require 'date'
```

## Using the DateTime Class

The base unit of the `DateTime` class is 1 day:

```ruby
puts DateTime.now
⇒ "2024-01-01T00:00:00+00:00"

puts DateTime.now + 1
⇒ "2024-01-02T00:00:00+00:00"
```

The `DateTime` class is convenient for dealing with extended period simulations, but when dealing with hours and minutes you may find it more convenient to use Ruby's `Time` class instead. The `Time` class uses 1 second as it's base unit:

```ruby
puts Time.now
⇒ "2024-01-01T00:00:00+00:00"

puts Time.now + 60
⇒ "2024-01-01T00:01:00+00:00"
```

To convert from a `DateTime` to a `Time`, use `<DateTime>.to_time`, and to convert back use `<Time>.to_datetime`. Workgroup methods expecting a `DateTime` will not work with `Time`.

### Creating new DateTime objects

You can create `DateTime` objects using the `new` method:

```ruby
puts DateTime.new(2001, 01, 01, 12, 45)
⇒ "2024-01-01T12:45:00+00:00"
```

You can also get the current time:

```ruby
right_now = DateTime.now
```

### Overriding Display Behaviour

By default, when a `DateTime` object is converted to a string (e.g. via the `puts` method) the output will appear like this:

```ruby
puts commit.date
⇒ "2023-12-25T16:58:50+01:00"
```

To customise the output you can use `strftime`:

```ruby
puts commit.strftime("%F %T")
⇒ "2023-12-25 17:00:37"
```

For the best compatibility with other systems, you should use the `<DateTime>.iso8601` method which returns a string in a standard format.

```ruby
puts commit.iso8601
⇒ "2023-12-25T10:36:50+01:00"
```

{::ICM}

## Dates and Times in Results

Simulations can use absolute or relative times, so the following convention is used:

- **Absolute times** are represented as a Ruby `DateTime` object
- **Relative times** are represented as a negative double (time in seconds)

{::/ICM}
