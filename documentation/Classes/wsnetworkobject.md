{WSPRO}

# WSNetworkObject

[WSModelObject](./wsmodelobject.md) > [WSBaseNetworkObject](./wsbasenetworkobject.md) > WSNetworkObject

A network using legacy lock version control.

**Methods:**

{{toc}}

## branched?

```ruby
#branched? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns if the network is branched.

## change_owner

```ruby
#change_owner(new_owner) ⇒ void
```

`EXCHANGE`

This method allows you to change the owner of a checked-out tree object. This could happen if the original owner is not available to undo the check-out or to check-in the object.

## check_in

```ruby
#check_in ⇒ void
```

`EXCHANGE`, `UI`

Checks in the network.

## check_out

```ruby
#check_out(new_name) ⇒ WSNetworkObject
```

`EXCHANGE`, `UI`

Checks out the network giving the checked out version a new name, and returns the new network.

**Parameters**

| Name     | Type(s) | Description                          |
| -------- | ------- | ------------------------------------ |
| new_name | String  | Name of the new checked out version. |

## check_out_and_branch

```ruby
#check_out_and_branch(new_name) ⇒ WSNetworkObject
```

`EXCHANGE`, `UI`

Checks out and branches the network, giving the checked out branch a new name, and returns the new network.

**Parameters**

| Name     | Type(s) | Description             |
| -------- | ------- | ----------------------- |
| new_name | String  | Name of the new branch. |

## checked_out?

```ruby
#checked_out? ⇒ Boolean
```

`EXCHANGE`, `UI`

Returns if the object is checked out.

## checked_out_by

```ruby
#checked_out_by ⇒ String
```

`EXCHANGE`, `UI`

Returns the user who has the network currently checked out.

**Parameters**

| Name   | Type(s) | Description                                                                                   |
| ------ | ------- | --------------------------------------------------------------------------------------------- |
| Return | String  | The user who has the object checked out, or an empty string if the object is not checked out. |

## undo_check_out

```ruby
#undo_check_out ⇒ void
```

`EXCHANGE`, `UI`

Undoes the check out operation i.e. effectively deletes this network.

The inherited [WSModelObject.delete](wsmodelobject.md) method will perform the same function, but this method will only work for checked out networks, so may be safer.
