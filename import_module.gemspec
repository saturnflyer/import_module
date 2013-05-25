# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'import_module/version'

Gem::Specification.new do |spec|
  spec.name          = "import_module"
  spec.version       = Import::Module::VERSION
  spec.authors       = ["Shin-ichiro HARA","Jim Gay"]
  spec.email         = ["sinara@blade.nagaokatut.ac.jp","jim@saturnflyer.com"]
  spec.description   = %q{incude modules dynamically}
  spec.summary       = %q{incude modules dynamically}
  spec.homepage      = ""
  spec.license       = "Ruby"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
