# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jreport/version'

Gem::Specification.new do |spec|
  spec.name          = "jreport"
  spec.version       = Jreport::VERSION
  spec.authors       = ["qjpcpu"]
  spec.email         = ["qjpcpu@gmail.com"]
  spec.summary       = %q{Jreport}
  spec.description   = %q{Create a report easily.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency 'mail'
  spec.add_runtime_dependency 'inline-style'
  spec.add_runtime_dependency 'erubis'
  spec.add_runtime_dependency 'sqlite3'
end
