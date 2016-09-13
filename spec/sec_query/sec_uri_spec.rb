# encoding: utf-8

include SecQuery
require 'spec_helper'

describe SecQuery::SecURI do
  describe '#browse_edgar_uri' do
    it 'builds a default /browse-edgar/ url' do
      uri = SecQuery::SecURI.browse_edgar_uri
      expect(uri.to_s).to eq('https://www.sec.gov/cgi-bin/browse-edgar')
    end

    it 'builds a default /browse-edgar/ url with options: {symbol: "AAPL"}' do
      uri = SecQuery::SecURI.browse_edgar_uri(symbol: 'AAPL')
      expect(uri.to_s)
        .to include('https://www.sec.gov/cgi-bin/browse-edgar?CIK=AAPL')
    end

    it 'builds a default /browse-edgar/ url with options: {cik: "AAPL"}' do
      uri = SecQuery::SecURI.browse_edgar_uri(cik: 'AAPL')
      expect(uri.to_s)
        .to include('https://www.sec.gov/cgi-bin/browse-edgar?CIK=AAPL')
    end

    it 'builds a default /browse-edgar/ url with options: "AAPL"' do
      uri = SecQuery::SecURI.browse_edgar_uri('AAPL')
      expect(uri.to_s)
        .to eq('https://www.sec.gov/cgi-bin/browse-edgar?CIK=AAPL')
    end

    it 'builds a default /browse-edgar/ url with options: "Apple"' do
      uri = SecQuery::SecURI.browse_edgar_uri('Apple')
      expect(uri.to_s)
        .to eq('https://www.sec.gov/cgi-bin/browse-edgar?company=Apple')
    end
  end

  describe 'Date additions' do
    subject(:d) { Date.parse('2012-04-26') }

    it 'calculates the correct quarter' do
      expect(d.quarter).to eq(2)
    end

    it 'calculates the correct sec formatted path uri for a date' do
      expect(d.to_sec_uri_format).to eq('2012/QTR2/company.20120426.idx')
    end
  end
end
