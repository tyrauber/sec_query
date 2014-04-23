# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'sec_query'
require 'support/vcr'

def is_valid?(entity)
  entity.should_not be_nil
  entity.name.should  == query[:name]
  entity.cik.should == query[:cik]
  entity.instance_variables.each do |key|
    SecQuery::Entity::COLUMNS.should include(key[1..-1].to_sym)
  end
end

def is_valid_address?(address)
  address.should_not be_nil
  address.keys.each do |key|
    ['city', 'state', 'street1', 'street2', 'type', 'zip', 'phone'].should include(key)
  end
end

def is_valid_filing?(filing)
  filing.should_not be_nil
  filing.instance_variables.each do |key|
    SecQuery::Filing::COLUMNS.should include(key[1..-1].to_sym)
  end
end