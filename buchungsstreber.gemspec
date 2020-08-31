lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buchungsstreber/version'

Gem::Specification.new do |spec|
  spec.name          = 'buchungsstreber-beta'
  spec.version       = Buchungsstreber::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['fhfet', 'jbuch', 'heib']
  spec.email         = ['heft@synyx.de', 'jonathan.buch@gmail.com', 'heib@synyx.de']

  spec.summary       = %q{Enables timely timekeeping.}
  spec.description   = "Streber."
  spec.homepage      = 'https://buchungsstreber.synyx.de'

  spec.metadata['allowed_push_host'] = 'https://nexus.synyx.de/content/repositories/gems/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://gitlab.synyx.de/synyx/buchungsstreber'
  spec.metadata['changelog_uri'] = 'https://gitlab.synyx.de/synyx/buchungsstreber/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|\.|Gem|Rake)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 0'
  spec.add_dependency 'i18n', '~> 0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'aruba', '~> 0.14.0'
  spec.add_development_dependency 'simplecov', '~> 0.17.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'gettext'
end
