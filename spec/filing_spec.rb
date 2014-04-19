# encoding: utf-8

include SecQuery
require 'spec_helper'

describe SecQuery::Filing do
  it '::uri_for_recent' do
    expect(SecQuery::Filing.uri_for_recent.to_s)
      .to eq('http://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent&company&count=100&output=atom&owner=include&start=0')
  end

  it '::uri_for_cik' do
    expect(SecQuery::Filing.uri_for_cik('testing').to_s)
      .to eq('http://www.sec.gov/cgi-bin/browse-edgar?CIK=testing&action=getcompany&company&count=100&output=atom&owner=include&start=0')
  end
end
