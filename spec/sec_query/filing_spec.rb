# encoding: utf-8
include SecQuery
require 'spec_helper'

describe SecQuery::Filing do
  it '::uri_for_recent' do
    expect(SecQuery::Filing.uri_for_recent.to_s)
      .to eq('https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent&company&count=100&output=atom&owner=include&start=0')
  end

  it '::uri_for_cik' do
    expect(SecQuery::Filing.uri_for_cik('testing').to_s)
      .to eq('https://www.sec.gov/cgi-bin/browse-edgar?CIK=testing&action=getcompany&company&count=100&output=atom&owner=include&start=0')
  end

  describe '::for_date', vcr: { cassette_name: 'idx' } do
    let(:index) { SecQuery::Filing.for_date(Date.parse('20161230')) }

    it 'parses all of the filings' do
      expect(index.count).to eq(2554)
    end

    it 'correctly parses out the link' do
      expect(index.first.link)
        .to match(/https:\/\/www.sec.gov\/Archives\/edgar\/data\//)
    end

    it 'correctly parses out the cik' do
      expect(index.first.cik).to eq('1605941')
    end

    it 'correctly parses out the term' do
      expect(index.first.term).to eq('N-CSR')
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
    shared_examples_for "it found filings" do
      it "should return an array of filings" do
        expect(filings).to be_kind_of(Array)
      end

      it "the filings should be valid" do
        is_valid_filing?(filings.first)
      end
    end

    let(:cik){"0000320193"}
    
    context "when querying by cik" do
      let(:filings){ SecQuery::Filing.find(cik) }

      describe "Filings", vcr: { cassette_name: "Steve Jobs"} do
        it_behaves_like "it found filings"
      end
    end
    
    context "when querying cik and by type param" do
      let(:filings){ SecQuery::Filing.find(cik, 0, 40, { type: "10-K" }) }

      describe "Filings", vcr: { cassette_name: "Steve Jobs"} do
        it_behaves_like "it found filings"

        it "should only return filings of type" do
          expect(filings.first.term).to eq "10-K"
        end
      end
    end
    
    describe '#content', vcr: { cassette_name: 'content' } do
      let(:index) { SecQuery::Filing.for_date(Date.parse('20161230')) }
      
      it 'returns content of the filing by requesting the link' do
        f = Filing.new(link: index.first.link)
        expect(f.content).to match(/^(<SEC-DOCUMENT>)/)
      end
    end

    describe "::last", vcr: { cassette_name: "Steve Jobs"} do
      let(:cik) { "0000320193" }

      context 'when querying by cik' do
        let(:filing) { SecQuery::Filing.last(cik) }

        it 'returns the first filing' do
          expect(filing).to be_kind_of(SecQuery::Filing)
          is_valid_filing?(filing)
        end
      end

      context 'when querying cik and by type param' do
        let(:filing) { SecQuery::Filing.last(cik,{ type: "10-K" }) }

        describe "Filings", vcr: { cassette_name: "Steve Jobs"} do
          it "should return filing of type 10-K" do
            expect(filing).to be_kind_of(SecQuery::Filing)
            expect(filing.term).to eq "10-K"
          end
        end
      end
    end
  end
end
