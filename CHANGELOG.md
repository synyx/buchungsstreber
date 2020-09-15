Changes
=======

## v2.3.0

* TUI gets a `today` argument  
  `buchungsstreber watch today`
* Documentation enhancements
* Performance enhancements/reduced API usage for TUI

## v2.2.6

* Fix generation in YAML format if file contains a single newline

## v2.2.5

* Bring YAML Format in line regarding generators

## v2.2.4

* Bugfix release regarding translations

## v2.2.3

* There is no release v2.2.3

## v2.2.2

* Revise TUI keys for exiting sub-window (enter, space, backspace)

## v2.2.1

* Add german and english translations

## v2.2.0

* Skip entering times already available on Redmine server
* Revise arrow keys in TUI
* Add `ncalcli` generator
* Bugfixes

## v2.1.x

* Enhance TUI with curses for entering hours
* Aggregate time entries
* Bugfixes

## v2.0.x

* Unstable development release
* Add TUI with curses for displaying hours
* Refactor application for extensibility
* Add concept of generators (generate entries if none exist)
* Add concept of resolvers (revise entries)
* Add CLI with more commands
* Add built-in initialization if no config exists
* Add built-in help on first-use

## v1.5.0

* Make installable as a ruby gem
* Provide commandline app `buchungsstreber`

# v1.2.0

* Add configuration option for working hours (8h by default)
    ```yaml
    hours: 8
    ```

## v1.1.0

* Support time spans as issue time (rounded up to quarters of an hour)

## v1.0.0

* Initial release
