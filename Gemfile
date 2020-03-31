source "https://rubygems.org"

# Specify your gem's dependencies in buchungsstreber.gemspec
gemspec

group :tui, optional: true do
  gem 'curses', '~>1.3', platform: :mri
  gem 'ffi-ncurses', platform: :jruby
  gem 'rb-inotify'
end
