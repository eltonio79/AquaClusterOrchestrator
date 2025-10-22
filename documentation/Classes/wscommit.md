{ALL}

# WSCommit

A single commit to a [WSModelObject](wsmodelobject.md) using merge version control.

The methods of this class are read only, and return the value in one of the fields that appears in the commit grid.

**Methods:**

{{toc}}

## branch_id

```ruby
#branch_id ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the branch ID.

## comment

```ruby
#comment ⇒ String
```

`EXCHANGE`, `UI`

Returns any comment associated with this commit. Comments are optional, so this may be an empty string.

## commit_id

```ruby
#commit_id ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the commit ID.

## date

```ruby
#date ⇒ DateTime
```

`EXCHANGE`, `UI`

Returns the date.

## deleted_count

```ruby
#deleted_count ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of objects that were deleted.

## inserted_count

```ruby
#inserted_count ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of objects that were inserted.

## modified_count

```ruby
#modified_count ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of objects that were modified.

## setting_changed_count

```ruby
#setting_changed_count ⇒ Integer
```

`EXCHANGE`, `UI`

Returns the number of settings that were changed.

Note: 'setting' is **not** plural.

## user

```ruby
#user ⇒ String
```

`EXCHANGE`, `UI`

Returns the username associated with this commit.
