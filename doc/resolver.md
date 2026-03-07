# Resolver

Resolver wandeln Daten aus der Timesheet-Datei in vorkonfigurierte Daten-Templates um.

## Buchungstemplates

Statt einer vollständigen Buchung kann ein Template verwendet werden, sodass nur dessen
Namen in der Buchung angegeben werden muss.

```yaml
templates:
  Frühstück:
    activity: Orga
    issue: S6325
    text: Frühstück
```
Die Buchung dazu sieht dann so aus:
```
10:45-12:00     Frühstück
```

## Match per regulärem Ausdruck

Matcht der Timesheet-Eintrag den regulären Ausdruck, wird er durch die 
konfigurierten Daten ersetzt. Sinnvoll in Kombination mit einem 
[Generator][generatoren]. `re` ist der reguläre Ausdruck, unter `entry` wird der
Buchungseintrag konfiguriert. 

  [generatoren]: generatoren.md

```yaml
resolvers:
  regexp:
    - re: bei Tiffany|Freitagsmeeting
      entry:
        activity: Orga
        issue: 6325
        redmine: S
        text: Frühstück
    - re: Daily
      entry: ...
```
Die generierte Buchung dazu sieht dann so aus:
```
10:45-12:00 Orga    S6325   Frühstück
```

## Issue Aliases

Statt überall Ticketnummern mit optionalen Redmine Prefix zu spezifizieren,
kann der IssueAlias Resolver genutzt werden. So kann ein Alias definiert werden,
das durch eine entsprechende Ticketnummer ersetzt wird.

Konfigurationsbeispiel:

```yaml
resolvers:
  issuealias:
    OrgaTicket: S12345
```

So würde eine Buchung wie:

```
10:30-11:30 Orga    OrgaTicket   Backlog aufräumen
```

folgendem entsprechen:

```
10:30-11:30 Orga    S12345   Backlog aufräumen
```