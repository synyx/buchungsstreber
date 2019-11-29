Buchungsstreber (⌐⊙_⊙)
======================

Der Buchungsstreber hilft beim konsistenten und zeitnahen Buchen in [Redmine](10), indem er 
in einer Textdatei gepflegte Buchungen automatisch in ein oder mehrere Redmine-Systeme überträgt.

  [10]: https://www.redmine.org
  
Voraussetzungen
---------------

- Ruby 2.0
- bundler (optional)
- schlechte Buchungsmoral
  
Installation
------------

1. Repository auschecken
2. Ruby-Gems installieren: `bundler install`
   (oder ohne bundler: `gem install colorize`)
3. `example.config.yml` nach `config.yml` kopieren
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

