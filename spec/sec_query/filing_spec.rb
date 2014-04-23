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

  describe "::find" do
    let(:query){{
     name: "JOBS STEVEN P", :cik => "0001007844",
      relationships:[
        {cik: "0000320193", name: "APPLE INC"},
        {cik: "0001001039", name: "WALT DISNEY CO/"},
        {cik: "0001002114", name: "PIXAR \\CA\\"}
      ],
      transactions:[
        {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares:120000.0},
        {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
        {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
        {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
        {filing_number: "0001181431-06-028746", reporting_owner: "WALT DISNEY CO/", shares: 138000004.0},
        {filing_number: "0001356184-06-000008", reporting_owner: "PIXAR \\CA\\", shares: 60000002.0},
        {filing_number: "0001181431-06-019230", reporting_owner: "APPLE COMPUTER INC", shares: 4573553.0},
        {filing_number: "0001181431-06-028747", reporting_owner: "WALT DISNEY CO/", shares: 0.0}
      ],
      filings:[
        {cik: "0001007844", file_id: "0001181431-07-052839"},
        {cik: "0001007844", file_id: "0001356184-06-000008"},
        {cik: "0001007844", file_id: "0001193125-06-103741"},
        {cik: "0001007844", file_id: "0001181431-06-028747"},
        {cik: "0001007844", file_id: "0001181431-06-028746"},
        {cik: "0001007844", file_id: "0001181431-06-019230"},
        {cik: "0001007844", file_id: "0001193125-06-019727"},
        {cik: "0001007844", file_id: "0001104659-03-004723"}
      ]
    }}
  
    let(:entity) {SecQuery::Entity.find(query[:cik])}
  
    describe "Filings", vcr: { cassette_name: "Steve Jobs"} do
      it "should respond to filings" do
        entity.should respond_to(:filings)
        entity.filings.should be_kind_of(Array)
      end
    
      it "should be valid filing" do
        is_valid_filing?(entity.filings.first)
      end
    end
  end
end
