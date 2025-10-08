# Changes

## v3.x.x

* Ruby 2 is now deprecated

## v2.12.2

* Update for Ruby >= 3.3
* Replace underlying TUI library (`ncursesw` -> `curses`)

## v2.11.1

* Fix time steps for non quarter hour ([#125](https://github.com/synyx/buchungsstreber/pull/125))

## v2.10.0

* Add dockerfile for containerized buchungsstreber
* Introduce DailyDoings ([#107](https://github.com/synyx/buchungsstreber/issues/107))
* Add creation time to `add` command ([#115](https://github.com/synyx/buchungsstreber/issues/115))
* Fix handling of empty YAML buchungen file
* Fix search path for config file

## v2.9.1

* Add Redmine Time Entry generator ([#101](https://github.com/synyx/buchungsstreber/issues/101))
* Fix potential data loss on generating entries ([#94](https://github.com/synyx/buchungsstreber/issues/94))

## v2.8.2

* Fix "Messy" YAML file when using the `add` feature ([#84](https://github.com/synyx/buchungsstreber/issues/84))

## v2.8.1

* Make sure entries get added in order ([#83](https://github.com/synyx/buchungsstreber/issues/83))

## v2.8.0

* Add time entries or notes from command line ([#11](https://github.com/synyx/buchungsstreber/issues/11))
* Template handling for Buch format ([#48](https://github.com/synyx/buchungsstreber/issues/48))
* Expand path configuration for Git generator
* Various housekeeping actions
* Introduce [Renovate](https://togithub.com/renovatebot/renovate)

## v2.7.0

* Fix confusing internationalized confirmation of saving entries in german
* Prefer VISUAL environment variable for opening editor
* Documentation enhancements
* Various generator fixes

## v2.6.2

* Remove usage of `/users/current` API endpoint to avoid issues with
  certain Redmine installations

## v2.6.1

* Bugfix regarding entries not getting aggregated in `buchen` action

## v2.6.0

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
