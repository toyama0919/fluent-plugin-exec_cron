# fluent-plugin-exec_cron [![Build Status](https://secure.travis-ci.org/toyama0919/fluent-plugin-exec_cron.png?branch=master)](http://travis-ci.org/toyama0919/fluent-plugin-exec_cron)

executes external programs with cron syntax.

## Examples

### minutely
```
<source>
  type exec_cron
  tag exec_cron.example
  command echo '{"a":"a"}'
  format json
  cron * * * * *
  graceful_shutdown false
</source>

<match exec_cron.example>
  type stdout
</match>
```

#### output
```
2015-05-27 13:07:00 +0900 exec_cron.example: {"a":"a"}
2015-05-27 13:08:00 +0900 exec_cron.example: {"a":"a"}
2015-05-27 13:09:00 +0900 exec_cron.example: {"a":"a"}
2015-05-27 13:10:00 +0900 exec_cron.example: {"a":"a"}
2015-05-27 13:11:00 +0900 exec_cron.example: {"a":"a"}
2015-05-27 13:12:00 +0900 exec_cron.example: {"a":"a"}
```

### hourly
```
<source>
  type exec_cron
  tag exec_cron.example
  command echo '{"a":"a"}'
  format json
  cron 0 * * * *
  graceful_shutdown true
</source>

<match exec_cron.example>
  type stdout
</match>
```

#### output
```
2015-05-27 12:00:00 +0900 exec_cron.example: {"a":"a"}
2015-05-27 13:00:00 +0900 exec_cron.example: {"a":"a"}
```


## Installation
```
sudo td-agent-gem install fluent-plugin-exec_cron
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Information

* [Homepage](https://github.com/toyama0919/fluent-plugin-exec_cron)
* [Issues](https://github.com/toyama0919/fluent-plugin-exec_cron/issues)
* [Documentation](http://rubydoc.info/gems/fluent-plugin-exec_cron/frames)
* [Email](mailto:toyama0919@gmail.com)

## Copyright

Copyright (c) 2015 Hiroshi Toyama

