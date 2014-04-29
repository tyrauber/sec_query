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
    let(:index) { File.read('./spec/sec_query/test.idx') }
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
end
