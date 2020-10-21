# Development

* [Environment](#environment)
* [Running tests](#running-tests)
* [Debugging](#debugging)

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

## I18n

The application is translated via `gettext`.

Basically, any string surrounded by the underscore method (`_('foo')`) is
meant to be localized.

The template for localized strings is in `lib/i18n/buchungsstreber.pot` and
can be updated by running `bundle exec rake xgettext`.  You probably have
to install `gettext` first.

After the `.pot` file has been updated, the translations can also be
updated.

### Current translations

* `de`: German (primary language)
* `de`: English (primary language)
* `en-029`: Caribbean (English without Unicode characters)

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
