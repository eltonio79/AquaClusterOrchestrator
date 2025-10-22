{ALL}

# Working with the Database

Ruby scripts can manipulate items in the database, which are known as model objects. User interface scripts have limited access to the database, while Exchange provides full support for creating, renaming, copying, and deleting model objects.

The most relevant classes are WSDatabase, and WSModelObject.

All model objects in the database tree have the following properties:

- Type - e.g. Network, Run, Selection List Group
- Name
- GUID - Globally Unique IDentifier, a long string of characters which can be found in the object properties in the UI
- Model ID - an integer which can be found in the object properties in the UI

Using this information, a model object can be referenced by:

- The type of object and it's GUID using `WSDatabase.model_object_from_type_and_guid`
- The type of object and it's model ID using `WSDatabase.model_object_from_type_and_id`
- The type of object and it's name using `WSDatabase.find_root_model_object` or `WSModelObject.find_child_model_object`
- The scripting path (described in more detail below) using `WSDatabase.model_object`

## Examples

### Example 1

{::ICM}

It is often easiest to use a model type and ID to access the model object. This example exports data for a rainfall event with ID 18:

```ruby
database = WSApplication.open

mo = database.model_object_from_type_and_id('Rainfall Event', 18)
mo.export('D:/Badger/Rainfall.csv', 'csv')
```

{::/ICM}

{::WSPRO}

It is often easiest to use a model type and ID to access the model object. This example exports data for a geometry network with ID 18:

```ruby
database = WSApplication.open

mo = database.model_object_from_type_and_id('Geometry', 18)
mo.export('D:/Badger/Network.csv', 'csv')
```

{::/WSPRO}

### Example 2

Alternatively, given the scripting path of an object you can access the object that way. This can sometimes be useful when you have to programmatically create the path.

This example exports binary results:

```ruby
SCRIPTING_PATH = '>MODG~Basic Initial Loss Runs>MODG~Initial Loss Type>RUN~Abs>SIM~M2-60'

database = WSApplication.open

sim_mo = database.model_object(SCRIPTING_PATH)
sim_mo.results_binary_export(nil, nil, 'D:/Badger/Sim.dat')
```

### Further Examples

It is possible to find all the objects in the root of the database using the `#root_model_objects` method of WSDatabase.

```ruby
database = WSApplication.open
database.root_model_objects.each { |o| puts o.path }
```

Similarly, it is possible to find all the children of a given object using the `#children` method.

This example finds all the root objects in the database, and then all the child objects of the root objects:

```ruby
database = WSApplication.open

database.root_model_objects.each do |o|
  o.children.each { |c| puts c.path }
end
```

These methods can be used recursively to find all the objects in the database. The technique used in the example below is a 'breadth first search' i.e. we start by finding the objects in the root of the database and putting them in an array. Thereafter we take the first object in the array, find its children, add them onto the end of the array and remove the first object.

```ruby
database = WSApplication.open

process = []
database.root_model_objects.each { |o| process << o }

until process.empty?
  working = process.shift() # Remove (and return) the first element from the array
  puts working.path
  working.children.each { |c| process << c }
end
```

Generally, where a model object is required in a method parameter, it can be passed as:

- The model ID, if the parameter can only be of one type
- A `WSModelObject` of the correct type
- The scripting path of the object

## Scripting Paths

Scripting paths are one way to uniquely identify a model object in the database, similar to a file path in your operating system. However, because it is possible to have two model objects of different types with the same name, each part of the scripting path must also include the type of the model object.

For example: a model group 'General', which contains another model group 'NorthArea', which contains a network 'MyNetwork':

`>CG~General>CG~NorthArea>GMT~MyNetwork`

A path always begins with `>`, then each level of the tree is formed by taking the model object type's 'short code', then a `~`, then it's name.

If the name of any model object contains the characters `~`, `>`, or `\`, then those characters must be escaped with a backslash, to avoid them being interpreted as part of the path.

For example, a model group with the unlikely name `My >>>~~~\\ Group` would have the path `>CG~My \>\>\>\~\~\~\\\\ Group`.
