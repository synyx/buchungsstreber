lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buchungsstreber/version'

Gem::Specification.new do |spec|
  spec.name          = 'buchungsstreber-tui'
  spec.version       = Buchungsstreber::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['jbuch', 'dgrammlich']
  spec.email         = ['jonathan.buch@gmail.com', 'grammlich@synyx.de']

  spec.summary       = %q{Enables timely timekeeping}
  spec.description   = "Enriches buchungsstreber with TUI."
  spec.homepage      = 'https://buchungsstreber.synyx.de'

  spec.metadata['allowed_push_host'] = 'https://nexus.synyx.de/content/repositories/gems/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://gitlab.synyx.de/synyx/buchungsstreber'
  spec.metadata['changelog_uri'] = 'https://gitlab.synyx.de/synyx/buchungsstreber/CHANGELOG.md'
  spec.files         = []

  spec.add_dependency 'buchungsstreber', Buchungsstreber::VERSION
  spec.add_dependency 'ncursesw', '~> 1.4.0'
  spec.add_dependency 'rb-inotify', '~> 0.10.0'
end
