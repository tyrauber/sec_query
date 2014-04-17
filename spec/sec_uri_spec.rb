# encoding: utf-8

include SecQuery
require 'spec_helper'

describe SecQuery::SecURI do
  describe '#browse_edgar_uri' do
    it 'builds a default /browse-edgar/ url' do
      uri = SecQuery::SecURI.browse_edgar_uri
      expect(uri.to_s).to eq('http://www.sec.gov/cgi-bin/browse-edgar')
    end

    it 'builds a default /browse-edgar/ url with options: {symbol: "AAPL"}' do
      uri = SecQuery::SecURI.browse_edgar_uri(symbol: 'AAPL')
      expect(uri.to_s)
        .to include('http://www.sec.gov/cgi-bin/browse-edgar?CIK=AAPL')
    end

    it 'builds a default /browse-edgar/ url with options: {cik: "AAPL"}' do
      uri = SecQuery::SecURI.browse_edgar_uri(cik: 'AAPL')
      expect(uri.to_s)
        .to include('http://www.sec.gov/cgi-bin/browse-edgar?CIK=AAPL')
    end

    it 'builds a default /browse-edgar/ url with options: "AAPL"' do
      uri = SecQuery::SecURI.browse_edgar_uri('AAPL')
      expect(uri.to_s)
        .to eq('http://www.sec.gov/cgi-bin/browse-edgar?CIK=AAPL')
    end

    it 'builds a default /browse-edgar/ url with options: "Apple"' do
      uri = SecQuery::SecURI.browse_edgar_uri('Apple')
      expect(uri.to_s)
        .to eq('http://www.sec.gov/cgi-bin/browse-edgar?company=Apple')
    end
  end
end
