# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/varys/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-varys"
  spec.version       = Rspec::Varys::VERSION
  spec.authors       = ["Ritchie Young"]
  spec.email         = ["ritchiey@gmail.com"]
  spec.summary       = %q{Generate RSpec specs from intelligence gathered from doubles and spies.}
  spec.description   = %q{Automatically track which assumptions you've made in the form or mocks and stubs actually work.}
  spec.homepage      = "https://github.com/ritchiey/rspec-varys"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", '~> 13.0', ">= 13.0"
  spec.add_development_dependency "rspec", '~> 3.1', ">= 3.1.0"
  spec.add_development_dependency "cucumber", '~> 6.1', ">= 6.1.0"
  spec.add_development_dependency "aruba", '~> 0.1', '>= 0.1.1'
  spec.add_dependency 'pp', '~> 0.2.0'
end
