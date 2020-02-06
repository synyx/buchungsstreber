# Tutorial

Vom Noob zum Buchungsstreber.

### Vorraussetzungen

* Ruby ist installiert
* Schlechte Buchungsmoral ist vorhanden
* [Gem Paketquelle][rubygems] ist eingerichtet

  [rubygems]: rubygems.md

## Installation

```
$ gem install buchungsstreber
```
## Erstmalige Einrichtung

```
$ buchungsstreber init
Konfiguration in $HOME/.config/buchungsstreber/config.yml erstellt.

Schritte zum friedvollen Buchen:
 * Config-Datei anpassen – mindestens die eigenen API-Keys eintragen.
 * Buchungsdatei oeffnen (siehe Konfig-Datei)
 * `buchungsstreber` ausfuehren
```

Gehe zu <https://project.synyx.de/my/account> oder anderen Redmine-Instanzen,
um API-Keys zu erstellen oder anzuzeigen.

```
$ buchungsstreber config
# $EDITOR (oder vim) oeffnet sich, zumindest die API-Keys sind einzutragen.
```

### Windows

Um Farben angezeigt zu bekommen, muss folgende Umgebungsvariable gesetzt sein.

```shell script
set THOR_SHELL=Color
```

## Meine erste Buchung

```
$ buchungsstreber edit
# $EDITOR (oder vim) oeffnet sich.
```

Nun sind im YAML-Format Buchungen anzulegen.  Erstmal die Einrichtung des
Buchungsstrebers buchen (Datum natuerlich anpassen):

```yaml
2019-06-17:
  - 0.5   Orga  S34530  Einrichtung Buchungsstreber
```

Diese Buchung mal Validieren lassen (ohne gleich im Redmine anzulegen):

```
$ buchungsstreber
BUCHUNGSSTREBER v1.5.1
~~~~~~~~~~~~~~~~~~~~~~

Buchungsübersicht:
Wed: 0.5h  @ Zeiten buchen                                     : Einrichtung Buchungsstreber   

Zu buchende Stunden (2019-12-11 bis 2019-12-11):
Wed: 0.5
Buchungen in Redmine übernehmen? (j/N)
N
Abbruch
```

Dann den rest des Tages noch fertig buchen, und hinterher auf `J` druecken,
um die Buchung zu komplettieren.

```
Buchungen in Redmine übernehmen? (j/N)
j
Buche 0.5h auf #34530: Einrichtung Buchungsstreber
→ OK
Buchungen erfolgreich gespeichert
```
