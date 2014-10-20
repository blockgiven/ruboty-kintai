# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty/kintai/version'

Gem::Specification.new do |spec|
  spec.name          = "ruboty-kintai"
  spec.version       = Ruboty::Kintai::VERSION
  spec.authors       = ["block_given?"]
  spec.email         = ["block_given@outlook.com"]
  spec.summary       = %q{ruboty plugin for 勤怠管理.}
  spec.homepage      = "https://github.com/blockgiven/ruboty-kintai"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ruboty"
  spec.add_runtime_dependency "tokiyomi"
  spec.add_runtime_dependency "activesupport"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
