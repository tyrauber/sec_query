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

  describe '::filings_for_index' do
    let(:index) { File.read('./spec/support/idx/test.idx') }
    let(:filing1) { SecQuery::Filing.filings_for_index(index).first }

    it 'parses all of the filings' do
      expect(SecQuery::Filing.filings_for_index(index).count).to eq(4628)
    end

    it 'correctly parses out the link' do
      expect(filing1.link)
        .to eq('http://www.sec.gov/Archives/edgar/data/38723/0000038723-14-000001.txt')
    end

    it 'correctly parses out the cik' do
      expect(filing1.cik).to eq('38723')
    end

    it 'correctly parses out the term' do
      expect(filing1.term).to eq('424B3')
    end
  end

  describe '::for_date' do
    let(:filings) do
      [].tap do |filings|
        SecQuery::Filing.for_date(Date.parse('20121123')) do |f|
          filings << f
        end
      end
    end

    let(:filing1) { filings.first }

    it 'correctly parses a filing from a zipped company index' do
      expect(filing1.term).to eq('4')
      expect(filing1.cik).to eq('1551138')
      expect(filing1.date).to eq(Date.parse('20121123'))
      expect(filing1.link)
        .to eq('http://www.sec.gov/Archives/edgar/data/1551138/0001144204-12-064668.txt')
    end

    it 'returns nil if for_date is run on a market close day' do
      expect(SecQuery::Filing.for_date(Date.parse('20120101'))).to eq(nil)
    end
  end

  describe '::recent', vcr: { cassette_name: 'recent' } do
    let(:filings) { [] }

    before(:each) do
      SecQuery::Filing.recent(start: 0, count: 10, limit: 10) do |filing|
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

    describe '#content', vcr: { cassette_name: 'content' } do
      it 'returns content of the filing by requesting the link' do
        f = Filing.new(
          cik: 123,
          title: 'test filing title',
          summary: 'test filing',
          link: 'http://www.sec.gov/Archives/edgar/data/1572871/000114036114019536/0001140361-14-019536.txt',
          term: '4',
          date: Date.today,
          file_id: 1
        )
        expect(f.content).to eq(File.read('./spec/support/filings/filing.txt'))
      end
    end
  end
end
