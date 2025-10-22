{ALL}

# Working with Networks

A Network in this context refers to a `WSModelObject` that contains tables and objects.

{::WSPRO}

This includes Geometry (called Network in the user interface), Control, and Live Data Configuration.

{::/WSPRO}

## Obtaining a Network

To work with individual objects within a network, you need to access a `WSOpenNetwork` instance. The mechanism for doing this is different between the UI and Exchange.

Within the UI:

```ruby
network = WSApplication.current_network()
```

Within Exchange, you need to first access the `WSNetworkObject` or `WSNumbatNetworkObject` class:

```ruby
database = WSApplication.open()
network_mo = database.model_object_from_type_and_id('Model Network', 2)
network = network.open
```

## Accessing Row Objects

Objects within a network are called row objects, represented by the `WSRowObject` class.

You can access objects specifically by type and ID:

```ruby
node = network.row_object('wn_node', 'Badger')
```

Or you can obtain an array of objects:

```ruby
nodes = network.row_objects('wn_node')
```

Or an array of selected objects:

```ruby
nodes = network.row_objects_selection('wn_node')
```

Categories can be used to obtain the objects across multiple tables. The most common use of a category is to obtain all of the nodes or links in a network, regardless of the types of the individual nodes or links.

The categories are:

{::ICM}

- `_nodes` - all nodes
- `_links` - all links
- `_subcatchments` - all subcatchments
- `_other` - other objects

{::/ICM}

{::WSPRO}

- `_nodes` - all nodes
- `_links` - all links
- `_other` - other objects

{::/WSPRO}

For example, to obtain an array of all nodes:

```ruby
nodes = network.row_objects('_nodes')
```

## Getting and Setting Values in Row Objects

### Named Fields

Named fields are the fixed properties of each type of object, which will be familiar to users of the software. A field can contain different types of data:

- Primitive data types - strings, numbers, booleans, etc which can be accessed and set directly
- Arrays - some fields contain arrays of data, e.g. pipe bends
- Structured data - represented by a `WSStructure` class, which is used to access and set rows of data
- Fake - not accessible to Ruby, but exist in the user interface to summarize other data

Flags are separate fields, i.e. a field `node_id` also has a field `node_id_flag`.

The real (database) name of a field may not match the interface name. The interface name is usually called the 'Description'.

#### Get / Set Methods

Getting and setting values can use the Array/Hash like [] and []= notation:

```ruby
value = ro['field'] # Get value from an object field
ro['field'] = value # Set value of an object field
```

Or using method like notation:

```ruby
value = ro.field # Get value from an object field
ro.field = value # Set value of an object field
```

Note that some fields are incompatible with the method like notation due to their name.

#### Nil Values

Fields can usually be set to `nil` which is the equivalent of being empty in the user interface, or `NULL` in SQL. Like SQL, some fields may contain an empty string value, which is not the same as `nil`.

Unlike SQL, `nil` values cannot be safely ignored. For example, this SQL script finds and selects pipes with a length less than or equal to 200:

```sql
DESELECT ALL;
SELECT WHERE length <= 200
```

An equivalent in Ruby:

```ruby
network.clear_selection
network.row_objects('_links').each do |ro|
  ro.selected = true if ro['length'] <= 200
end
```

But if a pipe had no length value, this would raise a runtime error because `nil` cannot be compared to `200`. You would catch this by checking the length is not `nil` first:

```ruby
network.clear_selection
network.row_objects('_links').each do |ro|
  ro.selected = true if (!ro['length'].nil? && ro['length'] <= 200)
end
```

#### Structure Blobs

A structure blob (or struct) is a field that contains structured rows of other data. In Ruby, it is represented by a `WSStructure` object which can be iterated over, with each element being a `WSStructureRow` containing named fields.

If we wanted to check what the first value of depth volume curve is, we could save the structure to a variable, then the first row (index 0), and access the field 'volume':

```ruby
depth_struct = res.depth_volume
depth_struct_row = depth_struct[0]
puts depth_struct_row['volume']
```

Or we could write this as one line:

```ruby
puts res.depth_volume[0]['volume']
```

We can write data to structs, though we have to be sure that there is already space using the `size=` method. Changes must be saved by using the `WSStructure.write` method, as well as `WSRowObject.write` on the object it belongs to.

```ruby
depth_struct = res.depth_volume
depth_struct[0]['volume'] = 100
depth_struct.write
res.write
```

#### Writing Changes

Changes to an object must be explicitly written to the `WSRowObject` using the `WSRowObject.write` method, which can only be done within a network transaction.

```ruby
network = WSApplication.current_network
network.clear_selection

network.transaction_begin
network.row_objects('cams_cctv_survey').each do |ro|
  ro['user_number_1'] = ro['surveyed_length'] / ro['total_length']
  ro['user_number_2'] = ro['total_length'] / ro['pipe_length']
  ro.write
end
network.transaction_commit
```

Setting the value of a field requires that value to be cast to a native InfoWorks type, and so it has to fit a strict criteria for the field: the correct type, length, etc.

### Tags

Tags are temporary values added to row objects for the duration of the script. They can be used for storing working values against a specific object, usually to aggregate or store them later, but are not saved and are lost when the script finishes.

The names of tags are not fixed but must begin with an underscore `_` and can only contain the letters a-z (without accents), digits, and underscores. They can also contain capitalised A-Z letters, but this is against Ruby naming conventions.

Getting and setting tag values can use the Array/Hash like [] and []= notation:

```ruby
value = ro['_tag_name'] # Get value of a tag
ro['_tag_name'] = value # Set value of a tag
```

Or using method like notation:

```ruby
value = ro._tag_name # Get value of a tag
ro._tag_name = value # Set value of a tag
```

- Unlike changes to object fields, tags do not need to be explicitly written to the `WSRowObject`
- There is no requirement that all values for a given tag name are the same, and any Ruby type is allowed
- While changes to object fields may be cached in the database, Ruby values are not, and so storing too much data could exceed the allowed memory allocation

### Choosing Notation

Which style of get / set notation you use is personal preference, however you may wish to use different notation for fields and tags to avoid ambiguity. In this case, using Hash syntax for named fields and method syntax for tags may be preferable:

```ruby
ro['field'] = value
ro._tag_name = value
```

## Saving Changes

### Network Transactions

Any change to objects within a network must be done within a transaction. The three relevant methods are:

- `WSOpenNetwork.transaction_begin` to begin a transaction
- `WSOpenNetwork.transaction_rollback` to rollback any changes made since the transaction was started
- `WSOpenNetwork.transaction_commit` to commit the changes made in this transaction

At this point, the changes will have been committed to the local working copy of network, but the changes are not committed to the database.

### Committing Changes

To commit changes to the database, you can use the `WSNumbatNetworkObject.commit` method from Exchange. You must have the model object for the network, which can be obtained using the `WSOpenNetwork.model_object` method.

The key differences in behavior between object fields and values, beyond that of the object field values having a life beyond the duration of the running of the script, are:

- Object field values must be explicitly written back to the local database for the network using the write method - since tags are not stored anywhere other than in working memory, the write method does not need to be called for them.
- Object field values can only be stored within an active 'transaction' (see below).
- Object field values are stored in the 'InfoWorks / InfoAsset' world. Any given field has a particular data type and, for string fields, a length. Any attempt to store values incompatible with the object's data type will fail. Tags, on the other hand, exist in the Ruby world and may therefore contain anything that can be stored in a Ruby variable. There is no requirement for all the values for different objects of the same tag to be of the same data type.
- Object field values may be cached in the database, allowing more objects and more data to be manipulated within a network than with tags, which always exist in memory. Using too many tags and storing too much data in them may cause the program's memory limit to be exceeded.

Flags are treated as being separate fields. Fields can, in general, be set to nil which is the equivalent of causing them to be blank in the user interface or setting them to NULL in SQL. NULL in SQL and nil in Ruby are essentially the same. Arrays e.g. of coordinates are returned as a Ruby array.

This example finds and selects pipes with width less than 200 or length less than 60 or, of course, both.

```ruby
net=WSApplication.current_network
net.clear_selection
ro=net.row_objects('cams_pipe').each do |ro|
  if (!ro.width.nil? && ro.width<200) || (!ro.length.nil? && ro.length<60)
    ro.selected=true
  end
end
```

This demonstrates a key difference between Ruby and SQL; in SQL it is safe to say width<200, the expression will ignore values which are NULL. In Ruby however, it is necessary to explicitly check for nil values, nil being the Ruby counterpart to NULL. If you fail to do this check a runtime error will be raised.

An equivalent way of writing the same script would be to use the [] notation as follows:

```ruby
net=WSApplication.current_network
net.clear_selection
ro=net.row_objects('cams_pipe').each do |ro|
  if (!ro['width'].nil? && ro['width']<200) || (!ro['length'].nil? && ro['length']<60)
    ro.selected=true
  end
end
```

In the rare cases where the field name begins with a digit or the `_` character it is necessary to use the `ro['fieldname']` form to access the value.

To set values it is necessary to:

- Set them within a transaction. Transactions are treated as a single unit for purposes of undo / redo. When run from the user interface, each transaction is treated as a single undo / redo step and appears in the menu as 'Scripted transaction'.
- Call the write method on the row object to explicitly put the values into the database. This is the equivalent in the user interface of finishing to edit an object, of which you might have changed a number of values.

This example sets a couple of users fields for CCTV surveys based on simple calculations performed on other fields:

```ruby
net=WSApplication.current_network
net.clear_selection
net.transaction_begin
ro = net.row_objects('cams_cctv_survey').each do |ro|
  ro['user_number_1'] = ro['surveyed_length'] / ro['total_length']
  ro['user_number_2'] = ro['total_length'] / ro['pipe_length']
  ro.write
end
net.transaction_commit
```

Since the parameter of the `[]` method is a Ruby string it can also be an expression. The following demonstrates this by storing the two values used on the right-hand side of the above expressions as string parameters, and building up the user field name as a string expression:

```ruby
net=WSApplication.current*network
net.clear_selection
net.transaction_begin
expressions=[['surveyed_length','total_length'],['total_length','pipe_length']]
ro=net.row_objects('cams_cctv_survey').each do |ro|
  (0...expressions.size).each do |i|
    ro['user_number*'+(i+1).to_s] = ro[expressions[i][0]] / ro[expressions[i][1]]
    ro.write
  end
end
net.transaction_commit
```

Once the user has run a script such as the above, the changes will have been made to the local network as though the change had been made manually in the user interface, or via SQL or similar, the changes have NOT been committed to the master database. It IS possible to commit the network to the master database by adding a call to the commit method with a suitable comment as a parameter e.g.

```ruby
net.commit 'set user fields'
```

Two users of tags, one simple and one more complex, are demonstrated below in the 'navigating between objects' section.

Various data fields in InfoWorks and InfoAsset are represented as 'structure blobs' - the field contains a number of 'rows' of values for each object which in some respects behave as though they are a sub-table - they have a number of named fields with values.

The structure blobs that are most common are the following:

- hyperlinks
- attachments
- material_details
- resource_details

Many tables contain a hyperlinks field. The following tables in asset networks contain one or more of the other three fields named above:

## Navigating Between Objects

You can navigate between objects by physical connectivity (e.g. the upstream node, the downstream links) or conceptual connectivity (e.g. the surveys for an asset, the assets for a survey).

### Nodes and Links

Nodes and links are instances of classes `WSNode` and `WSLink` respectively. The nodes have the methods `us_links` and `ds_links`, and the links have methods `us_node` and `ds_node`.

This code clears the selection, selects a node, iteratively selects its upstream links, their upstream nodes, then their upstream links etc.

```ruby
network = WSApplication.current_network
network.clear_selection

ro = network.row_object('cams_manhole', 'MH354671')
ro.selected=true
ro._seen=true

unprocessedLinks = []
ro.us_links.each do |l|
  if !l._seen
    unprocessedLinks << l
    l._seen=true
  end
end

while unprocessedLinks.size > 0
  working = unprocessedLinks.shift
  working.selected = true
  workingUSNode = working.us_node
  if !workingUSNode.nil? && !workingUSNode._seen
    workingUSNode.selected = true
    workingUSNode.us_links.each do |l|
      if !l._seen
        unprocessedLinks << l
        l.selected = true
        l._seen = true
      end
    end
  end
end
```

As well as demonstrating use of the us_links method of WSNode and the us_node method of WSLink, this demonstrate some other useful techniques:

- As with the examples listing the `WSModelObject` objects in a database, this demonstrates the use of a breadth first search - we add the upstream links of the node to an array, then work through the array from the front, taking the links from it, selecting them, then if they have an upstream node, getting the upstream links of that node and adding them to the back of the array. In this case we are using the shift method of the Ruby array, which returns the first item in the array, removing it from the array.
- Unlike the navigation of the database, where the objects are in a simple tree structure, networks can contain loops, therefore you will typically need to make sure that you only process any given node or link once, otherwise your script will keep revisiting the same objects over and over again. We do this by use of a tag which we have named `_seen`. Whenever we process a node or link we set the value of the `_seen` tag to true, and we ensure that we don't process nodes or links if they have got the tag set to true, signifying that they have already been processed.

### General

The more general way of navigating between objects is to use the `WSRowObject.navigate` (one-to-one, one-to-many) and `WSRowObject.navigate1` (one-to-one) methods.

The previous example may be rewritten using these methods as follows:

```ruby
network = SApplication.current_network
network.clear_selection

ro = network.row_object('cams_manhole','MH354671')
ro.selected = true
ro._seen = true

unprocessedLinks = []
ro.navigate('us_links').each do |l|
  if !l._seen
    unprocessedLinks << l
    l._seen = true
  end
end

while unprocessedLinks.size > 0
  working = unprocessedLinks.shift
  working.selected = true
  workingUSNode = working.navigate1('us_node')
  if !workingUSNode.nil? && !workingUSNode._seen
    workingUSNode.selected=true
    workingUSNode.navigate('us_links').each do |l|
      if !l._seen
        unprocessedLinks << l
        l.selected = true
        l._seen = true
      end
    end
  end
end
```

The only changes here are that calls to `us_links` are replaced by calls to `nagivate('us_links')` and the call to `us_link` is replaced by a call to `navigate1('us_link')`.

The navigate method however is much more versatile - this example navigates from CCTV surveys to pipes:

```ruby
net=WSApplication.current_network
interesting_codes=['ABC','DEF','GHI','JKL','MNO']
net.transaction_begin
net.row_objects('cams_pipe').each do |ro|
  (0...interesting_codes.size).each do |i|
    ro['user_number_'+(i+1).to_s]=nil
  end
  ro.write
end
codes=Hash.new
net.row_objects('cams_cctv_survey').each do |ro|
  ro.details.each do |d|
    code=d.code
    code_index=interesting_codes.index(code)
    if !code_index.nil?
      pipe=ro.navigate1('pipe')
      if pipe
        if pipe._defects.nil?
          pipe._defects=Array.new(interesting_codes.size,0)
        end
        pipe._defects[code_index]+=1
      end
    end
  end
end
net.row_objects('cams_pipe').each do |ro|
  if !ro._defects.nil?
    (0...interesting_codes.size).each do |i|
      ro['user_number_'+(i+1).to_s]=ro._defects[i]
    end
    ro.write
  end
end
net.transaction_commit
```

This clears user numbers 1 to 5 for all pipes, then iterates through all defects, counting the number of defects of 5 particular codes for each pipe, then stores those in user numbers 1 to 5.

Note the use of arrays stored in tags for temporary storage of counts.
