require "bundler/gem_tasks"
require "rspec/core/rake_task"

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

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
