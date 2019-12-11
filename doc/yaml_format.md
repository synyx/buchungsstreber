# YAML Buchungsformat

## Standard-Form

```yaml
Datum:
- [Zeit] [Aktivität] [Ticket-Nr.] [Beschreibung]
```

### Beispiel

```yaml
2019-01-01:
- 1.5   Orga  12345  Nachbereitung
```

## Templates

Konfiguration:

```yaml
templates:
  BeispielDaily:
    activity: Daily
    issue: S99999
    text: Daily
```

Buchung:

```yaml
- 0.5   BeispielDaily
```

Wird gebucht als:

```yaml
2019-01-01:
- 0.5   Daily  S99999  Daily
```

## Zeitangaben

Es sind Stunden-Angaben (`1.25`) sowie Zeitraeume (`Uhrzeit-Uhrzeit`) verwendbar.

```yaml
2019-01-01:
- 0.5         Daily  S99999  Daily
- 9:00-9:15   Daily  S99999  Daily
```

## Zeitgranularitaet

Zeiten werden auf eine Viertelstunde aufgerundet.


```yaml
2019-01-01:
- 7:00-7:25   Daily  S99999  Daily
```

Wird gebucht als:

```yaml
2019-01-01:
- 0.5        Daily  S99999  Daily
```

## Aggregation

```yaml
2019-01-01:
- 7:00-7:20   Daily  S99999  Daily
- 9:00-9:15          S99999
```

Wird gebucht als:

```yaml
2019-01-01:
- 0.75        Daily  S99999  Daily
```
