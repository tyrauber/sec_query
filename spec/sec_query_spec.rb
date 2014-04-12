include SecQuery
require 'spec_helper'

describe SecQuery::Entity do

  describe 'Company Queries', vcr: { cassette_name: "aapl"} do

    let(:apple) do
      { name: 'APPLE INC', sic: '3571', symbol: 'aapl', cik: '0000320193' }
    end

    context 'when quering by stock symbol' do
      it 'lazely' do
        entity = SecQuery::Entity.find(apple[:symbol])
        entity.cik.should eql(apple[:cik])
      end

      it 'explicitly' do
        entity = SecQuery::Entity.find(symbol: apple[:symbol])
        entity.cik.should eql(apple[:cik])
      end
    end

    context 'when querying by entity name' do
      it 'lazely' do
        entity = SecQuery::Entity.find(apple[:name])
        entity.cik.should eql(apple[:cik])
      end

      it 'explicitly' do
        entity = SecQuery::Entity.find(name: apple[:name])
        entity.cik.should eql(apple[:cik])
      end
    end

    context 'when querying by cik' do
      it 'lazely' do
        entity = SecQuery::Entity.find(apple[:cik])
        entity.name.should match(apple[:name])
      end

      it 'explicitly' do
        entity = SecQuery::Entity.find(cik: apple[:cik])
        entity.name.should match(apple[:name])
      end
    end
  end

  describe 'People Queries', vcr: { cassette_name: "Steve Jobs"} do
    let(:jobs) do
      { first: 'Steve', middle: 'P', last: 'Jobs', cik: '0001007844' }
    end

    context 'when querying by name' do
      it 'first, middle and last name' do
        entity = SecQuery::Entity.find(
          first: jobs[:first],
          middle: jobs[:middle],
          last: jobs[:last])
        entity.cik.should eql(jobs[:cik])
      end
    end
  end

  describe 'Relationships, Transactions and Filings', vcr: { cassette_name: "Steve Jobs"} do
    ## Using Steve, because data should not change in the future. RIP.

    let(:jobs) do
      { first: 'Steve', middle: 'P', last: 'Jobs', cik: '0001007844',
        relationships: [
          { cik: '0000320193', name: 'APPLE INC' },
          { cik: '0001001039', name: 'WALT DISNEY CO/' },
          { cik: '0001002114', name: 'PIXAR \\CA\\' }
        ],
        transactions: [
          { filing_number: '0001181431-07-052839', reporting_owner: 'APPLE INC', shares:120000.0 },
          { filing_number: '0001181431-07-052839', reporting_owner: 'APPLE INC', shares: 40000.0 },
          { filing_number: '0001181431-07-052839', reporting_owner: 'APPLE INC', shares: 40000.0 },
          { filing_number: '0001181431-07-052839', reporting_owner: 'APPLE INC', shares: 40000.0 },
          { filing_number: '0001181431-06-028746', reporting_owner: 'WALT DISNEY CO/', shares: 138000004.0 },
          { filing_number: '0001356184-06-000008', reporting_owner: 'PIXAR \\CA\\', shares: 60000002.0 },
          { filing_number: '0001181431-06-019230', reporting_owner: 'APPLE COMPUTER INC', shares: 4573553.0 },
          { filing_number: '0001181431-06-028747', reporting_owner: 'WALT DISNEY CO/', shares: 0.0 }
        ],
        filings: [
          { cik: '0001007844', file_id: '0001181431-07-052839' },
          { cik: '0001007844', file_id: '0001356184-06-000008' },
          { cik: '0001007844', file_id: '0001193125-06-103741' },
          { cik: '0001007844', file_id: '0001181431-06-028747' },
          { cik: '0001007844', file_id: '0001181431-06-028746' },
          { cik: '0001007844', file_id: '0001181431-06-019230' },
          { cik: '0001007844', file_id: '0001193125-06-019727' },
          { cik: '0001007844', file_id: '0001104659-03-004723' }
        ]
      }
    end

    let(:entity) do
      SecQuery::Entity.find(
        { first: 'Steve',
          middle: 'P',
          last: 'Jobs',
          cik: '0001007844' },
        true)
    end

    context 'when quering entities with option "true"' do
      it 'should provide relationships' do
        entity.relationships.each_with_index do |r, i|
          r.cik.should eql(jobs[:relationships][i][:cik])
        end
      end

      it 'should provide transactions' do
        entity.transactions.each_with_index do |t, i|
          t.filing_number.should eql(jobs[:transactions][i][:filing_number])
        end
      end

      it 'should provide filings' do
        entity.filings.each_with_index do |f, i|
          f.file_id.should eql(jobs[:filings][i][:file_id])
        end
      end
    end
  end
end
