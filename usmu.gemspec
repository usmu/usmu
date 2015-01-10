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
  spec.description   = <<-EOD
    Usmu is a static site generator built in Ruby that leverages the Tilt API to support many different template
    engines. It supports local generation but is designed to be used with the web-based editor.
  EOD
  spec.homepage      = 'https://github.com/usmu/usmu'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'slim', '~> 3.0'
  spec.add_dependency 'tilt', '~> 2.0'
  spec.add_dependency 'redcarpet', '~> 3.2', '>= 3.2.1'
  spec.add_dependency 'deep_merge', '~> 1.0'
  spec.add_dependency 'commander', '~> 4.2'
  spec.add_dependency 'logging', '~> 1.8'
  #spec.add_dependency 'pry'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'yard', '~> 0.8'
  spec.add_development_dependency 'guard', '~> 2.8'
  spec.add_development_dependency 'guard-rspec', '~> 4.3'
  spec.add_development_dependency 'libnotify', '~> 0.9'
  spec.add_development_dependency 'turnip', '~> 1.2'
  spec.add_development_dependency 'sass', '~> 3.4'
  spec.add_development_dependency 'timeout', '~> 0.0'
end
