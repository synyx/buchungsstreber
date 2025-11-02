lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buchungsstreber/version'

Gem::Specification.new do |spec|
  spec.name          = 'buchungsstreber'
  spec.version       = Buchungsstreber::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['fhfet', 'jbuch', 'grammlich', 'heib']
  spec.email         = ['heft@synyx.de', 'jonathan.buch@gmail.com', 'grammlich@synyx.de', 'heib@synyx.de']

  spec.summary       = %q{Titillates timely timekeeping.}
  spec.description   = "Streber."
  spec.homepage      = 'https://buchungsstreber.synyx.de'

  spec.metadata['allowed_push_host'] = 'https://nexus.synyx.de/content/repositories/gems/'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://gitlab.synyx.de/synyx/buchungsstreber'
  spec.metadata['changelog_uri'] = 'https://gitlab.synyx.de/synyx/buchungsstreber/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    excludes = %r{^(test|spec|features|\.|Gem|Rake|rubocop|simplecov|doc)/}
    `git ls-files -z`.split("\x0").reject { |f| f.match(excludes) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'i18n', '~> 1.14.0'
  spec.add_dependency 'thor', '~> 1.4'
  # add racc, not because it is needed directly, but because things just happen to be that way.
  spec.add_dependency 'racc', '~> 1.5'
  spec.add_dependency 'openssl', '~> 3.3'

  spec.add_development_dependency 'aruba', '~> 2.3'
  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'gettext', '~> 3.5'
  spec.add_development_dependency 'nexus', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 13.3'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.81'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
  spec.add_development_dependency 'webmock', '~> 3.25'
end
