{ALL}

# Add-ons

It is possible to store a CSV file containing the names of a number of scripts along with a name of a menu item to invoke them. These appear as sub-menu items of the ‘Run add-on’ menu item, which also appears on the ‘Network’ menu.

The CSV file must be stored in a directory below that used by the user’s application data named ‘scripts’ and must be called ‘scripts.csv’.

The name of the directory used by the user’s application data will vary according to the user’s set up, version of Windows etc. and can be found in the about box of the software as ‘NEP (iws) Folder’.
Having found this folder e.g.

`C:\Users\badgerb\AppData\Roaming\Innovyze\WorkgroupClient`

Add a sub-directory called ‘scripts’.

The folder may also be determined by using the `WSApplication.add_on_folder` method, this will return the path of the scripts folder i.e. `C:\Users\badgerb\AppData\Roaming\Innovyze\WorkgroupClient\scripts` in this case.

In this scripts.csv file you should add a CSV file containing 2 columns, the first being the menu item for the script, the second the path for the script file itself.

The paths for the script files may either be fully qualified paths (i.e. beginning with a drive letter or the name of a network share) in which case that path will be used, or a non-fully qualified path in which case the software will assume the file is in the folder containing the csv file or a subdirectory of it.

Changes to this file only take effect when the application is restarted.
