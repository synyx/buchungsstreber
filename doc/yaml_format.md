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

## Issue Aliases

Konfiguration:

```yaml
issues:
  AliasFuerIssue: S99999
```

Buchung:

```yaml
- 0.5  Daily AliasFuerIssue Daily
```

Wird gebucht als:

```yaml
2019-01-01:
- 0.5   Daily  S99999  Daily
```

Issue Aliases koennen auch in Template verwendet werden.

## Zeitangaben

Es sind Stunden-Angaben (`1.25`) sowie Zeitraeume (`Uhrzeit-Uhrzeit`) verwendbar.

```yaml
2019-01-01:
- 0.5         Daily  S99999  Daily
- 9:00-9:15   Daily  S99999  Daily
```

## Zeitgranularitaet

Zeiten werden aufgerundet. Die mindestens zu buchende Zeit kann über die
Konfiguration `minimum_time` konfiguriert werden. Ist beispielsweise eine
Viertelstunde konfiguriert

```
minimum_time: 0.25
``` 

wird

```yaml
2019-01-01:
- 7:00-7:25   Daily  S99999  Daily
```

gebucht als

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
