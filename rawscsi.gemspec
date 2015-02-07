# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rawscsi/version'

Gem::Specification.new do |spec|
  spec.name          = "rawscsi"
  spec.version       = Rawscsi::VERSION
  spec.authors       = ["Steven Li"]
  spec.email         = ["StevenJLi@gmail.com"]
  spec.description   = %q{Ruby Amazon Web Services Cloud Search Interface}
  spec.summary       = %q{Adds service objects to upload and search active record models with AWS Cloud Search }
  spec.homepage      = "https://github.com/stevenjl/rawscsi"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "3.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "pry"
  
  unless RUBY_VERSION == "1.8.7"
    spec.add_development_dependency "activerecord", "> 2.0"
    spec.add_dependency "httparty", "~> 0.11"
    spec.add_dependency "faraday", "0.9.1"
    spec.add_dependency "faraday_middleware"
  else
    spec.add_development_dependency "activerecord", "2.0"
    spec.add_dependency "httparty", "0.8"
    spec.add_dependency "faraday", "=0.8.7"
    spec.add_dependency "faraday_middleware", ">= 0.8.0"
    spec.add_dependency "json"
  end
end

