{ALL}

# Running Scripts From the User Interface

Ruby scripts may be run from the user interface when a network is open. The script can access the current network via the `WSApplication.current_network` method.

When a script is running in the user interface, anything directed to `stdout` or `stderr` (e.g. using the `puts`, `warn`, or `printf` methods) is displayed in a log window once the script finishes. It is not displayed in real time.

You are allowed to create selection list groups when running Ruby scripts from the user interface.

There are three ways to run external scripts from the User Interface. Configuring Add-Ons and User Actions may be useful if you are automating a repeat task, particularly if you want to share these with your team.

## From the Network Menu

In the Network menu, use 'Run Ruby Script...' to locate and run a script file. The 'Recent Scripts' sub-menu will show previously run scripts.

## As an Add-On

Add-ons are configured per user, and allow you to save frequently run scripts as a menu item.

## As a User Action

User Actions are similar to Add-Ons, but support more than just Ruby Scripts. These can be configured in the File > Database Settings > User Custom Actions window.

Tip: You can also use a Ruby script database item, rather than an external script, to run a script from the user interface.
