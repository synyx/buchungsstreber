# Buchungsstreber via Rubygems

## Einmalige Einrichtung

Falls man den buchungsstreber via Rubygems installiert hat, sollte die
Paketquelle schon vorhanden sein.
Falls nicht, kann diese mit folgenden Kommandos hinzugefuegt werden:

```shell script
set +o history
gem source add --source https://<user>:<pass>@nexus.synyx.de/content/repositories/gems`
set -o history
```

In der `.gemrc` wird so eine neue source eingefuegt.

## Update

Update (bzw. Installation wenn nicht schon geschehen) geht danach ueber:

```shell script
gem update buchungsstreber
```
