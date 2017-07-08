# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_parse/version'

Gem::Specification.new do |spec|
  spec.name          = 'log_parse'
  spec.version       = LogParse::VERSION
  spec.authors       = ['Travis Dempsey']
  spec.email         = ['dempsey.travis@gmail.com']
  spec.summary       = 'Simple field extraction log parser'
  spec.homepage      = 'https://github.com/kornypoet/log_parse'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject{ |f| f.match(%r{^spec/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}){ |f| File.basename f }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.0'
end
