# Buch Buchungsformat

## Standard-Form

```
Datum

[<redmine>]#<ticketnr> <zeit> <activity> <text>
```

### Beispiel

```
2019-01-01

#1234    1.5 Daily  Maint Daily
s#25888  0.5 Orga   Buchungsdext
```

## Zeitangaben

Es sind Stunden-Angaben (`1.25`, `1:15`) verwendbar.

```
#1234   1.25  Orga  Meeting
#1234   1:15  Orga  Meeting
```

## Zeitgranularitaet

Zeiten werden auf eine Viertelstunde aufgerundet.

```
#1234   1:10  Orga  Meeting
```

Wird gebucht als:

```
#1234   1.25  Orga  Meeting
```
