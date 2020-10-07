# Resolver

Resolver wandeln Daten aus der Timesheet-Datei in vorkonfigurierte Daten-Templates um.

## Buchungstemplates

Statt einer vollständigen Buchung kann ein Template verwendet werden, sodass nur dessen
Namen in der Buchung angegeben werden muss.

````
templates:
  Frühstück:
    activity: Orga
    issue: S6325
    text: Frühstück
````
Die Buchung dazu sieht dann so aus:
````
10:45-12:00     Frühstück
````

## Match per regulärem Ausdruck

Matcht der Timesheet-Eintrag den regulären Ausdruck, wird er durch die 
konfigurierten Daten ersetzt. Sinnvoll in Kombination mit einem 
[Generator][generatoren]. `re` ist der reguläre Ausdruck, unter `entry` wird der
Buchungseintrag konfiguriert. 

  [generatoren]: generatoren.md

````
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
````
Die generierte Buchung dazu sieht dann so aus:
````
10:45-12:00 Orga    S6325   Frühstück
````
