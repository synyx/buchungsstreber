Buchungsstreber (⌐⊙_⊙)
======================

Der Buchungsstreber hilft beim konsistenten und zeitnahen Buchen in [Redmine][redmine], indem er
in einer Textdatei gepflegte Buchungen automatisch in ein oder mehrere Redmine-Systeme überträgt.

  [redmine]: https://www.redmine.org
  
Voraussetzungen
---------------

- Ruby 2.x
- bundler (optional)
- schlechte Buchungsmoral
  
Installation
------------

1. `gem install buchungsstreber` (Mit eingerichteter [Paketquelle][rubygems])
2. `buchungsstreber init`
3. Config-Datei anpassen – mindestens die eigenen API-Keys eintragen

  [rubygems]: doc/rubygems.md

or via git repository:

1. Repository auschecken
2. Ruby-Gems installieren: `bundle install --path vendor/bundle`
3. `bundle exec buchungsstreber init`
4. Config-Datei anpassen – mindestens die eigenen API-Keys eintragen

Nutzung
-------

Buchungen werden als Plaintext erfasst, jede Zeile entspricht dabei einer Buchung.
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

Entwicklung
-----------

[![coverage report](https://gitlab.synyx.de/synyx/buchungsstreber/badges/master/coverage.svg)](https://gitlab.synyx.de/synyx/buchungsstreber/commits/master)

Ab und zu mal tests ausfuehren.

```
bundle exec rspec
```
