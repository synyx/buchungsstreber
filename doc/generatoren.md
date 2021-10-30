# Generatoren

Generatoren beziehen Daten von externen Programmen und generieren 
Daten in der Timesheet-Datei. Diese Einträge können manuell oder per 
[Resolver][resolver] in buchungskonforme Einträge verändert werden.

  [resolver]: resolver.md

## Importiere Nextcloud- / Owncloud-Termine per ncalcli

ncalcli: [Installation und Dokumentation](https://github.com/BuJo/ncalcli)

### Konfiguration des Buchungsstrebers

Alle Termine generieren:
````
generators:
  ncalcli: {}
````

Bestimmte Termine ignorieren, `ignore` ist ein regulärer Ausdruck:
````
generators:
  ncalcli:
    ignore: Hunderunde|Mittagspause
````

## Buchungseinträge aus Git-Commits generieren

Der Generator erzeugt Buchungsstreber-Einträge anhand von Git-Commits.

### Konfiguration des Buchungsstrebers

Repositories konfigurieren, die betrachtet werden sollen:
````yaml
generators:
  git:
    dirs: 
      - ~/Projects/buchungsstreber
````

## Buchungseinträge aus E-Mails generieren

Der Generator basiert auf einem experimentellen, nicht unterstützen Skript `cmi`
das E-Mails durchsucht und gewünschte Treffer wieder ausgibt.
Der Generator erzeugt Buchungsstreber-Einträge anhand der gefilterten E-Mails.
Welche Ausgabe vom Generator erwartet wird kann dem
[dazugehörigen Spec](spec/generator/mail_spec.rb) entnommen werden.

### Konfiguration des Buchungsstrebers

````yaml
generators:
  mail: {}
````

## Buchungseinträge aus Erwähnungen in Redmine-Kommentaren generieren

Der Generator basiert auf einem experimentellen, nicht unterstützen Skript `cmm`
das alle Zeiteinträge in Redmine nach Schlagwörtern durchsucht und Einträge mit
möglichen Erwähnungen ausgibt. 
Der Generator erzeugt Buchungsstreber-Einträge anhand der gefilterten Einträge.
Welche Ausgabe vom Generator erwartet wird kann dem
[dazugehörigen Spec](spec/generator/mention_spec.rb) entnommen werden.

### Konfiguration des Buchungsstrebers

````yaml
generators:
  mention: {}
````

## Buchungseinträge aus Erwähnungen in Redmine-Kommentaren generieren

Der Generator basiert auf einem experimentellen, nicht unterstützen Skript `cmr`
das Aktivitäten eines Benutzers aus Redmine heraussucht und zurückgibt.
Der Generator erzeugt Buchungsstreber-Einträge anhand der ausgegebenen
Aktivitäten.
Welche Ausgabe vom Generator erwartet wird kann dem
[dazugehörigen Spec](spec/generator/redmine_spec.rb) entnommen werden.

### Konfiguration des Buchungsstrebers

````yaml
generators:
  redmine: {}
````

## Buchungseinträge aus XChat-Logs generieren

Der Generator basiert auf einem experimentellen, nicht unterstützen Skript `cmx`
das [XChat](http://xchat.org/)-Logs einliest, diese nach Schlagwörtern filtert 
und wieder ausgibt.
Der Generator erzeugt Buchungsstreber-Einträge anhand der gefilterten Logs. 
Welche Ausgabe vom Generator erwartet wird kann dem
[dazugehörigen Spec](spec/generator/xchat_spec.rb) entnommen werden.

### Konfiguration des Buchungsstrebers

````yaml
generators:
  xchat: {}
````
