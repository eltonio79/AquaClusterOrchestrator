{ALL}

# Introduction to Scripts

This documentation describes the Ruby API for external scripts that run within the user interface and Exchange.

For those of you who are not familiar with Ruby scripts, an Introduction to Ruby Scripting in InfoWorks topic is included in the product help.

Scripts that run from the user interface are designed to work with the current network, including importing and exporting data, but have limited access to the database. Exchange is a command line application that can run scripts with far greater access to database objects, making it well suited to more complex automation.

|                                 **Task** | **User Interface** | **Exchange** |
| ---------------------------------------: | :----------------: | :----------: |
| Add, Import, and Manipulate Network Data |         ✔          |      ✔       |
|                Commit and Revert Changes |         ✔          |      ✔       |
|    Display Dialogs and other UI Features |         ✔          |      ❌      |
|    Manipulate any other Database Objects |         ❌         |      ✔       |
|                  Open or Close Databases |         ❌         |      ✔       |
|              Configure & Run Simulations |         ❌         |      ✔       |

Ruby scripts are only intended to manipulate data via the product's documented API. While you can use most features of the [Ruby Standard Library](https://ruby-doc.org/stdlib-2.4.0/), you cannot install and use external packages (gems).

The application uses an embedded Ruby 2.4.0 interpreter.

This example script displays the number of nodes in the network:

```ruby
network = WSApplication.current_network
nodes = network.row_objects('_nodes')
puts format("Your Network has %i nodes!", nodes.length)
```

## Reading this Documentation

Ruby is a flexible language with many conventions and style guides. The examples in this documentation try to follow best practices.

### Methods

Throughout this documentation, methods are described in this format:

```ruby
#method(param1, param2) ⇒ Integer?
```

Where `⇒` indicates a return from the method, followed by the most commonly returned type.

- `void` means that you should not expect a return value
- A question mark means that the type may be nil (NULL)
- An array is written as `Array<String>` where the contents of the `<>` indicates the type of object the array will contain

### Naming Conventions

- PascalCase for Modules and Classes
- SCREAMING_SNAKE_CASE for constants
- snake_case for variables and methods
- Variables for workgroup objects are often abbreviated in examples, e.g. a `WSRowObject` will be `ro`, `WSModelObject` is `mo`

Note that in the 2025.0 release, several methods which included capitalization were updated to be all lowercase. While the previous method names still work for backwards compatibility, we recommend using the newer method names for consistency.

Options hashes will not follow these guidelines and may include spaces and punctuation.

### Other Conventions

- Two space width for indentation (either spaces or tabs)
- Use literal syntax to define arrays and hashes i.e. `my_hash = {}` instead of `my_hash = Hash.new`

## Tips

- You can check if an object (e.g. the value from a field) is nil with `.nil?`
- If you want to call a method but are unsure if the object is nil, use the safe navigator `&` i.e. `array&.empty?`
- For concise code, try the following:
  - Ruby supports some opposite conditions / actions, e.g. `if` and `unless`, `while` and `until`
  - To do one thing based on a condition, instead of writing a three line if statement, use `(action) if (condition)` i.e. `puts 'Hi' if 5 > 2`
  - If you want to set a value conditionally, use the ternary operator `(condition) ? (true) : (false)` i.e. `animal = (3 > 4) ? 'badger' : 'penguin'`
