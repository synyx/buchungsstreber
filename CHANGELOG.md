Changes
=======

## v.2.6.0

Note that this release contains backwards-compatibility breaking changes.

* Remove deprecated `gcalcli` generator
* TUI behavioural change: Using the enter key after committing the times will
  now switch to the next day, escape will stay on current day
* The curses library used for the TUI was replaced due to instability
* A separate `buchungsstreber-tui` gem will be published for easier TUI usage

## v2.5.0

* Add color configuration for redmines
* Make minimum time per entry configurable
* Minor and major bugfixes while moving from GitLab to GitHub as platform
* Add an english README file
* Add general documentation for a more open development and contribution guidelines

## v2.4.0

* ncalcli generator can now filter shown entries
* behavioral change:  regexp resolver will now override non-empty fields in entries

## v2.3.1

* Relax validation for duplicated entries

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
