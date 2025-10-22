{ALL}

# Character Encoding

The behaviour of strings passed into / returned by Ruby methods is determined by the `WSApplication.use_utf8` setting. The default value is false.

If this setting is set to true, the methods will expect strings passed into methods to have UTF8 encoding, and will return UTF8 strings.

If this setting is set to false, the methods will expect strings passed into methods will have the locale appropriate encoding, and will return strings in that encoding.

The strings are expected to be passed in with the correct encoding - the encoding is not checked, and strings with a different encoding do not have their encoding changed.

If you are using constant strings in your Ruby scripts you will find things go much more smoothly if you use the corresponding encoding in your script. As well as ensuring that the script file is in the encoding you think it is, you need to communicate this to Ruby by setting the encoding in the first line of the script e.g

```ruby
# encoding: UTF-8
```

| **Language**       | **Encoding** | **Synonym** |
| ------------------ | ------------ | ----------- |
| Bulgarian          | Windows-1251 |             |
| Japanese           | Shift_JIS    | CP932       |
| Korean             | CP949        |             |
| Simplified Chinese | GBK          | CP936       |
| Turkish            | Windows-1254 | CP857       |
| Western European   | Windows-1252 | CP1252      |
| \*                 | UTF-8        |             |
