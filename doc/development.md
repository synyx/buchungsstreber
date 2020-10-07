# Development

* [Environment](#environment)
* [Running tests](#running-tests)

## Environment

To set up your environment we recommend to install Bundler.
````
gem install bundler
````
Now you can install all necessary dependencies and start `buchungsstreber`.

````
bundle install --with=tui
bundle exec ./bin/buchungsstreber
````

## Running tests

You can run `rspec` with
````
bundle exec rspec
````
If you just want to execute a specific test run
````
bundle exec rspec spec/my_spec.rb
````

## Debugging

To get the full exception instead of only a little message use `--debug`.

```
buchungsstreber show --debug 2020-01-01
```

As for the TUI, it is built with curses, so it will most probably swallow
all your exceptions and stacktraces.
If you're using a Bash like Shell and you're using printf style debugging:

```
buchungsstreber watch --debug 2020-01-01 2>error.log
```

This will output the standard error to the given file.
