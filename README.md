Buchungsstreber (⌐⊙_⊙)
======================

![CI](https://github.com/synyx/buchungsstreber/workflows/CI/badge.svg)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=com.github.synyx%3Abuchungsstreber&metric=security_rating)](https://sonarcloud.io/dashboard?id=com.github.synyx%3Abuchungsstreber)

Lost? -> [English README][english].

Der Buchungsstreber hilft beim konsistenten und zeitnahen Buchen in [Redmine][redmine], indem er
in einer Textdatei gepflegte Buchungen automatisch in ein oder mehrere Redmine-Systeme überträgt.

  [redmine]: https://www.redmine.org
  [english]: README_en.md

* [Schnacken](#schnacken)
* [Voraussetzungen](#voraussetzungen)
* [Installation](#installation)
* [Konfiguration](#konfiguration)
* [Nutzung](#nutzung)
* [Terminal User Interface](#terminal-user-interface)
* [Entwicklung](#entwicklung)

Schnacken
---------

Fragen?  Hilfe notwendig?  Einfach nur mal Schnacken?

* Matrix: [#buchungsstreber:synyx.de](https://matrix.to/#/!BxFxbjMxhzwOlFxvMm:synyx.de/)
* E-Mail: [buchungsstreber@synyx.de](mailto:buchungsstreber@synyx.de)
* [Contribution Guidelines][contributing]

  [contributing]: CONTRIBUTING.md

Voraussetzungen
---------------

- Ruby 2.x
- bundler (optional)
- schlechte Buchungsmoral
  
Installation
------------

1. `gem install buchungsstreber` (Mit eingerichteter [Paketquelle][rubygems])

  [rubygems]: doc/rubygems.md

Oder via git Repository:

1. Repository auschecken
2. Ruby-Gems installieren: `bundle install`

Konfiguration
------------

1. Initialisierung durchfuehren lassen via
   `buchungsstreber init`

Oder

1. Konfigurationspfad für Buchungstreber erstellen:
`mkdir ~/.config/buchungsstreber`

2. Config-Datei anhand der [Beispiel-Config](example.config.yml) erstellen.

Mindestens die eigenen Redmine-API-Keys eintragen, ggf. auch den Pfad zur
Buchungs-Datei `timesheet_file` und (je nach Arbeitsweise) den Archiv-Ordner
`archive_path` anpassen: `buchungsstreber config` (edit
`~/.config/buchungsstreber/config.yml`).

Nutzung
-------

Bei erstmaliger Anwendung hilft das [TUTORIAL](./doc/tutorial.md).

Buchungen werden als Plaintext erfasst, vgl. [Beispiel](example.buchungen.yml). Jede Zeile entspricht dabei einer Buchung.
Eine "Datums-Überschrift" spezifiert das Datum der darunter folgenden Buchungen.

Eine Buchungs-Zeile hat dabei immer folgendes Format (getrennt durch Tabs oder Leerzeichen):
```yaml
- [Zeit] [Aktivität] [Ticket-Nr.] [Beschreibung]
```

### Beispiel:
```yaml
2019-01-01:
- 1.5   Orga  12345  Nachbereitung
```
In diesem Fall würden für den *01.01.2019* eineinhalb Stunden auf das Ticket #12345 gebucht. 
Die Aktivität wäre dabei "Orga" und die Beschreibung "Nachbereitung".

Vollstaendige Beschreibungen fuer:

* [YAML Format](./doc/yaml_format.md)
* [Buch Format](./doc/buch_format.md)

### Let's buch it

Sobald ein paar Buchungen eingetragen sind, sollte der Buchungsstreber einfach
gestartet werden können durch: `buchungsstreber`

Keine Sorge, der Buchungsstreber validiert erst einmal die Einträge in der
Buchungs-Datei und bucht nicht direkt los.


## Terminal User Interface

Mit curses ist eine Oberflaeche vorhanden, welche zur Ueberpruefung von
Buchungen sowie zum abschliessenden Buchen verwendet werden kann.

```shell script
buchungsstreber watch today
buchungsstreber watch 2020-09-01
```

Benoetigt werden hierzu noch Rubygem Abhaengigkeiten:

* `curses`
* `listen` oder `rb-inotify` oder `filewatcher`

Bedienungsanleitung erreichbar mit `h`.


Entwicklung
-----------

* [Development Guide](./doc/development.md)
