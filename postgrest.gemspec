# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postgrest/version'

Gem::Specification.new do |spec|
  spec.name          = "postgrest"
  spec.version       = PostgREST::VERSION
  spec.authors       = ["JC Wilcox"]
  spec.email         = ["84jwilcox@gmail.com"]

  spec.summary       = %q{ActiveRecord-esque wrapper for PostgREST API}
  spec.description   = %q{A Ruby wrapper for querying a PostgREST API (similar to Active Record)}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "pg", "~> 0.18"
  spec.add_dependency "httparty", "~> 0.13"
end
