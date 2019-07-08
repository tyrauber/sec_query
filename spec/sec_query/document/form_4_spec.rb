# encoding: utf-8
include SecQuery
require 'spec_helper'

describe SecQuery::Document::Form4, vcr: { cassette_name: 'form_4' } do
  let(:uri) { 'https://www.sec.gov/Archives/edgar/data/320193/000032019318000137/wf-form4_153877878310747.xml' }
  subject(:document) { SecQuery::Document::Form4.fetch(uri) }

  it 'captures top level document info' do
    expect(document.type).to eq '4'
    expect(document.subject_to_section_16).to be true
    expect((Date.strptime(document.period_of_report, '%Y-%m-%d') rescue false)).to be_a Date
  end

  describe '#issuer' do
    subject(:issuer) { document.issuer }

    it 'parses the issuer' do
      expect(issuer['cik']).to eq '0000320193'
      expect(issuer['name']).to eq 'APPLE INC'
      expect(issuer['trading_symbol']).to eq 'AAPL'
    end
  end

  describe '#reporting_owner' do
    subject(:reporting_owner) { document.reporting_owner }

    it 'parses the reporting owner' do
      expect(reporting_owner['cik']).to eq '0001496686'
      expect(reporting_owner['name']).to eq 'WILLIAMS JEFFREY E'
      expect(reporting_owner['address']).to eq({'street1'=>'ONE APPLE PARK WAY', 'street2'=>nil, 'city'=>'CUPERTINO', 'state'=>'CA', 'zip_code'=>'95014', 'state_description'=>nil})
      expect(reporting_owner['is_director']).to eq false
      expect(reporting_owner['is_officer']).to eq true
      expect(reporting_owner['is_other']).to eq false
      expect(reporting_owner['other_text']).to eq nil
      expect(reporting_owner['officer_title']).to eq 'COO'
    end

    context 'multiple reporting_owners' do
      let(:uri) { 'https://www.sec.gov/Archives/edgar/data/314943/000120919118010464/doc4.xml' }

      it 'parses the (first) reporting owner' do
        expect(reporting_owner['cik']).to eq '0001067983'
        expect(reporting_owner['name']).to eq 'BERKSHIRE HATHAWAY INC'
        expect(reporting_owner['address']).to eq({"street1"=>"3555 FARNAM STREET", "street2"=>nil, "city"=>"OMAHA", "state"=>"NE", "zip_code"=>"68131", "state_description"=>nil})
        expect(reporting_owner['is_director']).to eq false
        expect(reporting_owner['is_officer']).to eq false
        expect(reporting_owner['is_other']).to eq false
        expect(reporting_owner['other_text']).to eq nil
        expect(reporting_owner['officer_title']).to eq nil
      end
    end
  end

  describe '#remarks' do
    subject(:remarks) { document.remarks }

    xit 'parses the remarks' do
      # Not yet implemented, this example has no remarks
    end
  end

  describe '#footnotes' do
    subject(:footnotes) { document.footnotes }

    it 'parses the footnotes' do
      expect(footnotes.count).to eq 3
      footnotes.each do |footnote|
        expect(footnote.length).to be > 0
      end
    end
  end

  describe '#securities' do
    subject(:securities) { document.securities }

    it 'parses the securities' do
      securities.each do |security|
        expect(security['type']).to eq 'Common Stock'
        expect(security['type_footnote'].length).to be > 0
        expect((Date.strptime(security['transaction_date'], '%Y-%m-%d') rescue false)).to be_a Date
        expect(security['coding']).to eq({'form_type'=>'4', 'code'=>'S', 'equity_swap_involved'=>false})

        expect(security['amounts']['shares']).to be_a Integer
        expect(security['amounts']['price_per_share']).to be_a Float
        expect(['A', 'D']).to include(security['amounts']['acquired_disposed_code'])

        expect(security['price_per_share_footnote'].length).to be > 0
        expect(security['post_transaction_amounts']['shares_owned']).to be > 0
        expect(security['ownership_nature']).to eq({'direct_or_indirect_ownership'=>'D'})
      end
    end

    context 'only one security' do
      let(:uri) { 'https://www.sec.gov/Archives/edgar/data/314943/000120919118010464/doc4.xml' }

      it 'parses the securities' do
        expect(securities.count).to eq 1
        security = securities.first
        expect(security['type']).to eq 'Common Stock'
        expect(security['type_footnote']).to be_nil
        expect((Date.strptime(security['transaction_date'], '%Y-%m-%d') rescue false)).to be_a Date
        expect(security['coding']).to eq({'form_type'=>'4', 'code'=>'D', 'equity_swap_involved'=>false})

        expect(security['amounts']['shares']).to be_a Integer
        expect(security['amounts']['price_per_share']).to be_a Float
        expect(['A', 'D']).to include(security['amounts']['acquired_disposed_code'])

        expect(security['price_per_share_footnote']).to be_nil
        expect(security['post_transaction_amounts']['shares_owned']).to be > 0
        expect(security['ownership_nature']).to eq({'direct_or_indirect_ownership'=>'I'})
      end
    end
  end

  describe '#to_h' do
    subject(:hash) { document.to_h }

    it 'builds the hash' do
      expect(hash.keys).to eq ['type', 'period_of_report', 'subject_to_section_16', 'issuer', 'reporting_owner', 'securities', 'footnotes', 'remarks']
      expect(hash['type']).to eq '4'
      expect(hash['subject_to_section_16']).to be true
      expect((Date.strptime(hash['period_of_report'], '%Y-%m-%d') rescue false)).to be_a Date
      expect(hash['issuer']).to be_a Hash
      expect(hash['reporting_owner']).to be_a Hash
      expect(hash['securities']).to be_a Array
      expect(hash['footnotes']).to be_a Array
      expect(hash['remarks']).to be_a Array
    end
  end
end
