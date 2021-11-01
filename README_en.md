Buchungsstreber (⌐⊙_⊙)
======================

The Buchungsstreber (translated roughly as 'time entry nerd') helps you adding time entries to
[Redmine][redmine].  It enables writing a simple text file and will take care of adding those
entries to one or more [Redmine][redmine] instances.

  [redmine]: https://www.redmine.org

* [Help](#help)
* [Requirements](#requirements)
* [Installation](#installation)
* [Configuration](#configuration)
* [Usage](#usage)
* [Terminal User Interface](#terminal-user-interface)
* [Development](#development)

Help
----

Questions?  Help needed?  Simply wanna talk?

* Matrix: [#buchungsstreber:synyx.de](https://matrix.to/#/!BxFxbjMxhzwOlFxvMm:synyx.de/)
* E-Mail: [buchungsstreber@synyx.de](mailto:buchungsstreber@synyx.de)
* [Contribution Guidelines][contributing]

  [contributing]: CONTRIBUTING.md

Requirements
---------------

- Ruby 2.x
- bundler (optional)
- bad time entry moral
  
Installation
------------

1. `gem install buchungsstreber` (With configured [package resource][rubygems])

  [rubygems]: doc/rubygems.md

Or via git repository:

1. Check out repository
2. Install needed gems: `bundle install`

Configuration
-------------

1. Initialize configuration with
   `buchungsstreber init`

Or

1. Create configuration path:
`mkdir ~/.config/buchungsstreber`

2. Create config using the [example config](example.config.yml).

Add at least the own redmine API key and the path to your time entry file
`timesheet_file`.
Depending on the usage you also need to configure the archive folder
`archive_path`.

You can edit the configuration using `buchungsstreber config` (or editing
`~/.config/buchungsstreber/config.yml`).

Usage
-------

You can visit the [TUTORIAL](./doc/tutorial.md) if using it the first time.

Time entries are done as plaintext files, see [Example](example.buchungen.yml).  Each
line represents one time entry.

A line is done according to this specification, each token separated by spaces or tabs:
```yaml
- [Zeit] [Aktivität] [Ticket-Nr.] [Beschreibung]
```

### Example:
```yaml
2019-01-01:
- 1.5   Orga  12345  Nachbereitung
```
In this case, there would be a time entry on the 1st January for one and a half
hours on ticket #12345.
The activity would be organizational in nature and has a text after that.

Full descriptions for the two current plaintext formats:

* [YAML Format](./doc/yaml_format.md)
* [Buch Format](./doc/buch_format.md)

### Let's buch it

As soon as there is at least one time entry, the Buchungsstreber can be run
via `buchungsstreber`.

Don't worry, the Buchungsstreber will validate the entries first, and will
not enter completely bogus times.

## Terminal User Interface

There is a curses based interface, which can be used to validate the entries
and to enter the times into Redmine instances.

```shell script
buchungsstreber watch today
buchungsstreber watch 2020-09-01
```

To use the TUI interface, there are some more gem requirements:

* `curses`
* `listen` oder `rb-inotify` oder `filewatcher`

You can reach a help interface by pressing `h`.

Development
-----------

* [CONTRIBUTING](./CONTRIBUTING.md)
* [Development Guide](./doc/development.md)
