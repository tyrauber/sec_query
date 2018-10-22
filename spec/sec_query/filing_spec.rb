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
  end

  describe '#detail', vcr: { cassette_name: 'Steve Jobs'} do
    let(:cik) { '0000320193' }
    let(:filing) { SecQuery::Filing.find(cik, 0, 1, {type: type}).first }
    subject(:filing_detail) { filing.detail }

    shared_examples 'Valid SecQuery::FilingDetail' do |filing_type|
      it 'valid filing detail' do
        expect(filing_detail).to be_a SecQuery::FilingDetail
        expect((Date.strptime(subject.filing_date, '%Y-%m-%d') rescue false)).to be_a Date
        expect((DateTime.strptime(subject.accepted_date, '%Y-%m-%d %H:%M:%S') rescue false)).to be_a DateTime
        expect((Date.strptime(subject.period_of_report, '%Y-%m-%d') rescue false)).to be_a Date
        expect(filing_detail.sec_access_number).to match /^[0-9]{10}-[0-9]{2}-[0-9]{6}$/ # ex: 0000320193-18-000100
        expect(filing_detail.document_count).to be > 0


        expect(filing_detail.data_files).not_to be_empty if filing_type == '10-K'
        expect(filing_detail.data_files).to be_empty if filing_type == '4'
        expect(filing_detail.format_files).not_to be_empty
      end
    end

    context '10-K' do
      let(:type) { '10-K' }
      it_behaves_like 'Valid SecQuery::FilingDetail', '10-K'
    end

    context 'Form 4' do
      let(:type) { '4' }
      it_behaves_like 'Valid SecQuery::FilingDetail', '4'
    end
  end
end
