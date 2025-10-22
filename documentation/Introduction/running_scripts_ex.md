{ALL}

# Running Scripts from Exchange

## Autodesk Licensing

{::ICM}

ICM Exchange is the IExchange implementation of InfoWorks ICM for our Autodesk products. It is only available for users with an [Ultimate license](GUID-0D4199AC-F739-42B5-B0BF-160EEC248FAB.html).

### Usage

`ICMExchange [options] [--] script [-login|-l] [args]`

{::/ICM}

{::WSPRO}

WS Pro Exchange is the IExchange implementation of InfoWorks WS Pro for our Autodesk products. This uses the [license](GUID-59E409D2-07FF-4F1F-B22A-C762914F17CE.html) set to InfoWorks WS Pro.

### Usage

`WSProExchange [options] [--] script [-login|-l] [args]`

{::/WSPRO}

| Parameter    | Description                                                                                                                                                                                                                                                                                                               |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| options      | (Optional) These are any ruby command line options. See Command Line Options.                                                                                                                                                                                                                                             |
| --           | (Optional) Separator for the ruby command line options.                                                                                                                                                                                                                                                                   |
| script       | The path of the ruby script. Make sure to surround with "" if it contains spaces.                                                                                                                                                                                                                                         |
| -login or -l | (Optional) When set, it displays the Autodesk Identity web page for users to log-in. If the user is already logged-in, it will proceed without showing the web page. If not set and the user is not logged-in, it will show the error: "Autodesk Licensing Error: The licence is not authorised (3).unable to initialise" |
| args         | (Optional) It is possible to provide more arguments to the script with the extra arguments.                                                                                                                                                                                                                               |

Note: Subscription overuse rules should apply.

## Innovyze Licensing

`IExchange [options] [--] script [product] [args]`

| Parameter | Description                                                                                                                    |
| --------- | ------------------------------------------------------------------------------------------------------------------------------ |
| options   | (Optional) These are any ruby command line options. See Command Line Options.                                                  |
| --        | (Optional) Separator for the ruby command line options.                                                                        |
| script    | The path of the ruby script. Make sure to surround with "" if it contains spaces.                                              |
| product   | The product code - either ICM, IA, or WS                                                                                       |
| args      | (Optional) It is possible to provide extra arguments to the script. Make sure to surround them with "" if they contain spaces. |

## Additional Arguments

It is possible to provide more arguments to the script to custodies it's behavior, such as which database or network it should work with.

{::ICM}

`ICMExchange.exe "C:/Badger/my_script.rb" one two`

{::/ICM}

{::WSPRO}

`WSProExchange.exe "C:/Badger/my_script.rb" one two`

{::/WSPRO}

Like regular Ruby scripts, the command line arguments are accessed from the `ARGV` array. The first element of the array is always the string 'ADSK'. For the above example, the `ARGV` array would contain:

`['ADSK', one, two]`

And the first custom argument could be accessed with `ARGV[1]`.

Note that when using Innovyze licensing, the first element is a string of the product code instead of 'ADSK':

{::ICM}

`['ICM', one, two]`

{::/ICM}

{::WSPRO}

`['WS', one, two]`

{::/WSPRO}
