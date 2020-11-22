require "rake/clean"
CLOBBER.include "pkg"

require "bundler/gem_helper"
Bundler::GemHelper.install_tasks name: 'buchungsstreber'
Bundler::GemHelper.install_tasks name: 'buchungsstreber-tui'

desc 'Regenerate Translation Template'
task :xgettext do
  lib = File.expand_path('lib', __dir__)
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
  require 'buchungsstreber/version'

  args = [
    '--copyright-holder=Jonathan Buch <jbuch@synyx.de>',
    "--package-version=#{Buchungsstreber::VERSION}",
    '--package-name=BUCHUNGSSTREBER',
    '--msgid-bugs-address=jbuch@synyx.de',
    '--sort-by-msgid',
    '--output=./lib/buchungsstreber/i18n/buchungsstreber.pot',
    Dir.glob('lib/buchungsstreber/cli/*.rb'),
  ].flatten
  system('rxgettext', *args)
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
