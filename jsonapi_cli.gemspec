# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jsonapi_cli/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Simon Chiang"]
  gem.email         = ["simon.a.chiang@gmail.com"]
  gem.description   = "Utilities to work with JSONAPI"
  gem.summary       = "Utilities to work with JSONAPI"
  gem.homepage      = ""

  gem.files         = []
  gem.executables   = Dir.glob("bin/jsonapi*").map {|file| File.basename(file) }
  gem.test_files    = []
  gem.name          = "jsonapi"
  gem.require_paths = ["lib"]
  gem.version       = JsonapiCli::VERSION
end
