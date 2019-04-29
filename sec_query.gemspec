# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'sec_query/version'

Gem::Specification.new do |s|
  s.name        = 'sec_query'
  s.version     = SecQuery::VERSION
  s.authors     = ['Ty Rauber']
  s.email       = ['tyrauber@mac.com']
  s.license       = 'MIT'
  s.homepage    = 'https://github.com/tyrauber/sec_query'
  s.summary     = 'A ruby gem for querying the United States Securities and Exchange Commission Edgar System.'
  s.description = 'Search for company or person, by name, symbol or Central Index Key (CIK), and retrieve filings.'

  s.rubyforge_project = 'sec_query'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 2.0.1'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'vcr', '~> 3.0'
  s.add_development_dependency 'webmock', '~> 2.3'
  s.add_development_dependency 'rubocop', '~> 0.52'
  s.add_development_dependency 'byebug', '~> 9.0'
  s.add_runtime_dependency 'rest-client', '~> 2.0'
  s.add_runtime_dependency 'addressable', '~> 2.5'
  s.add_runtime_dependency 'nokogiri', '>= 1.8.5'
  s.add_runtime_dependency 'activesupport', '>= 0'
end