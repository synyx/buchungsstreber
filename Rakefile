require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc 'Regenerate Translation Template'
task :xgettext do
  args = [
    '--language=Ruby',
    '--indent',
    '--add-location',
    '--sort-output',
    '--output=./lib/buchungsstreber/i18n/buchungsstreber.pot',
    'lib/buchungsstreber/cli/*.rb',
  ]
  system('xgettext', *args)
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
