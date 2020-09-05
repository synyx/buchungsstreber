source "https://rubygems.org"

# Specify your gem's dependencies in buchungsstreber.gemspec
gemspec

group :tui, optional: true do
  gem 'curses', '~>1.3'
  gem 'rb-inotify'
end

group :dev, optional: true do
  gem 'pronto'
  gem 'pronto-rubocop'
  gem 'pronto-flay'
end
