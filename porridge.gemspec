# frozen_string_literal: true

require_relative 'lib/porridge/version'

# Obviously this block needs to be long.
# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'porridge'
  spec.version       = Porridge::VERSION
  spec.authors       = ['Jacob']
  spec.email         = ['jacoblockard99@gmail.com']

  spec.summary       = 'A flexible, object-oriented approach to Ruby serialization.'
  spec.description   = <<~DESC
    `porridge` is a plain Ruby gem that takes a flexible, object-oriented approach to serialization. `porridge`
    transforms objects into ruby hashes and arrays, which can then be serialized with other libraries.
  DESC
  spec.homepage      = 'https://github.com/jacoblockard99/porridge'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'byebug', '~> 11.1'
  spec.add_development_dependency 'rspec', '~> 4.0'
  spec.add_development_dependency 'rubocop', '~> 1.24'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.7'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
# rubocop:enable Metrics/BlockLength
