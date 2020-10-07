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
