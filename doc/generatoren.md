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
