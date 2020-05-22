# Buchungsstreber via Rubygems

## Einmalige Einrichtung

Falls man den buchungsstreber via Rubygems installiert hat, sollte die
Paketquelle schon vorhanden sein.
Falls nicht, kann diese mit folgenden Kommandos hinzugefuegt werden:

```shell script
gem source --add https://nexus.synyx.de/content/repositories/gems/
```

In der `.gemrc` wird so eine neue source eingefuegt.

## Installation

```shell script
gem install buchungsstreber
```

Alle `gem` Kommandos muessen entweder mit `sudo` ausgefuehrt werden oder mit
der option `--user-install`, um die Gems ins Homeverzeichnis zu installieren.
Fuer `--user-install` siehe die FAQ fuer [User Install][userinstall].

  [userinstall]: https://guides.rubygems.org/faqs/#user-install

### Windows

* https://rubyinstaller.org/downloads/
  Am besten als normaler Benutzer (nicht als Administrator) installieren (sonst Schmerzen).

* Start Command Prompt with Ruby
  ```shell script
  gem install buchungsstreber
  ```

## Update

Update geht danach ueber:

```shell script
gem update buchungsstreber
```

## Neue Version releasen

```shell script
vim lib/buchungsstreber/version.rb
git commit
git tag v<version>
bundle exec rake build
gem nexus pkg/buchungsstreber-<version>.gem
```
