# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'sec_query'
require 'support/vcr'

def is_valid?(entity)
  expect(entity).to_not be_nil
  expect(entity.name).to eq query[:name]
  expect(entity.cik).to eq query[:cik]
  entity.instance_variables.each do |key|
    expect(SecQuery::Entity::COLUMNS).to include(key[1..-1].to_sym)
  end
end

def is_valid_address?(address)
  expect(address).to_not be_nil
  address.keys.each do |key|
    expect(['city', 'state', 'street1', 'street2', 'type', 'zip', 'phone']).to include(key)
  end
end

def is_valid_filing?(filing)
  expect(filing).to_not be_nil
  filing.instance_variables.each do |key|
    expect(SecQuery::Filing::COLUMNS).to include(key[1..-1].to_sym)
  end
end