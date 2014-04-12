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
    ['cik', 'name', 'company_info', 'mailing_address', 'business_address'].should include(key.to_s[1..-1])
  end
end

def is_valid_company_info?(company_info)
  company_info.should_not be_nil
  company_info.keys.each do |key|
    ['addresses', 'assigned_sic', 'assigned_sic_desc', 'assigned_sic_href', 'assitant_director', 'cik', 'cik_href', 'conformed_name', 'fiscal_year_end', 'formerly_names', 'state_location', 'state_location_href', 'state_of_incorporation'].should include(key)
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
    [:@cik, :@accession_nunber, :@act, :@file_number, :@file_number_href, :@filing_date, :@filing_href, :@filing_type, :@film_number, :@form_name, :@size, :@type].should include(key)
  end
end