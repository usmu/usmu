# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'usmu/version'

Gem::Specification.new do |spec|
  spec.name          = 'usmu'
  spec.version       = Usmu::VERSION
  spec.authors       = ['Matthew Scharley']
  spec.email         = ['matt.scharley@gmail.com']
  spec.summary       = %q{A static site generator with a web-based frontend for editing.}
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.platform      = 'jruby'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'slim', '~> 2.1'
  spec.add_dependency 'tilt', '~> 2.0'
  spec.add_dependency 'kramdown', '~> 1.5'
  spec.add_dependency 'deep_merge', '~> 1.0'
  spec.add_dependency 'trollop', '~> 2.0'
  spec.add_dependency 'highline', '~> 1.6'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'cucumber', '~> 1.3'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'cane', '~> 2.6'
end