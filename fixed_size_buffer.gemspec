# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fixed_size_buffer/version'

Gem::Specification.new do |spec|
  spec.name = 'fixed_size_buffer'
  spec.version = FixedSizeBuffer.version
  spec.authors = ['Justin Howard']
  spec.email = ['jmhoward0@gmail.com']

  spec.summary = 'A circular data structure'
  spec.homepage = 'https://github.com/justinhoward/fixed_size_buffer'
  spec.license = 'MIT'

  rubydoc = 'https://www.rubydoc.info/gems'
  spec.metadata = {
    'changelog_uri' => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'documentation_uri' => "#{rubydoc}/#{spec.name}/#{spec.version}"
  }

  spec.files = Dir['*.md', '*.txt', 'lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency 'rspec', '~> 3.4'
  # 0.81 is the last rubocop version with Ruby 2.3 support
  spec.add_development_dependency 'rubocop', '0.81.0'
  spec.add_development_dependency 'rubocop-rspec', '1.38.1'
end
