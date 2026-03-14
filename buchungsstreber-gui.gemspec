lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buchungsstreber/version'

Gem::Specification.new do |spec|
  spec.name          = 'buchungsstreber-gui'
  spec.version       = Buchungsstreber::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['jbuch']
  spec.email         = ['jonathan.buch@gmail.com']

  spec.summary       = %q{Enables timely timekeeping}
  spec.description   = "Enriches buchungsstreber with GUI."
  spec.homepage      = 'https://buchungsstreber.synyx.de'

  spec.metadata['allowed_push_host'] = 'https://nexus.synyx.de/content/repositories/gems/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://gitlab.synyx.de/synyx/buchungsstreber'
  spec.metadata['changelog_uri'] = 'https://gitlab.synyx.de/synyx/buchungsstreber/CHANGELOG.md'
  spec.files         = []

  spec.add_dependency 'buchungsstreber', Buchungsstreber::VERSION
  spec.add_dependency 'glimmer-dsl-libui', '~> 1.4.0'
  spec.add_dependency 'concurrent-ruby', '~> 1.1.9'
end
