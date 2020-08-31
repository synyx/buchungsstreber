require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc 'Regenerate Translation Template'
task :xgettext do
  `xgettext --language=Ruby --indent --add-location --sort-output --output=./lib/buchungsstreber/i18n/buchungsstreber.pot lib/buchungsstreber/cli/*.rb`
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
