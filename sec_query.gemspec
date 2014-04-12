# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'sec_query/version'
require 'sec_query'

Gem::Specification.new do |s|
  s.name        = 'sec_query'
  s.version     = SecQuery::VERSION
  s.authors     = ['Ty Rauber']
  s.email       = ['tyrauber@mac.com']
  s.homepage    = 'https://github.com/tyrauber/sec_query'
  s.summary     = 'A ruby gem for querying the United States Securities and Exchange Commission Edgar System.'
  s.description = 'Search for company or person, by name, symbol or Central Index Key (CIK), and retrieve relationships, transactions and filings.'

  s.rubyforge_project = 'sec_query'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']


  s.add_development_dependency 'rspec', '>= 2.14'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rubocop'
  s.add_runtime_dependency 'rest-client'
  s.add_runtime_dependency 'hpricot'

   s.add_runtime_dependency 'nokogiri'
   s.add_runtime_dependency 'hashie'
   s.add_runtime_dependency 'crack'
end
