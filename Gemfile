source "https://rubygems.org"

# Specify your gem's dependencies in buchungsstreber.gemspec
gemspec :name => 'buchungsstreber'

group :tui, optional: true do
  # Keep in sync with buchungsstreber-tui dependencies
  gem 'ncursesw', '~>1.4.0'
  gem 'rb-inotify', '~>0.10.0'
end

group :gui, optional: true do
  # Keep in sync with buchungsstreber-gui dependencies
  gem 'glimmer-dsl-libui', '~>0.5.4'
  gem 'concurrent-ruby', '~>1.1.9'
end
