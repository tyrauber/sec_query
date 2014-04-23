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

  describe '::recent', vcr: { cassette_name: 'recent' } do
    let(:filings) { [] }
    before(:each) do
      SecQuery::Filing.recent({start: 0, count: 10, limit: 10}) do |filing|
        filings.push filing
      end
    end

    it 'should accept options' do
      expect(filings.count).to eq(10)
    end

    it 'should have filing attributes', vcr: { cassette_name: 'recent' } do
      filings.each do |filing|
        expect(filing.cik).to be_present
        expect(filing.title).to be_present
        expect(filing.summary).to be_present
        expect(filing.link).to be_present
        expect(filing.term).to be_present
        expect(filing.date).to be_present
        expect(filing.file_id).to be_present
      end
    end
  end
end
