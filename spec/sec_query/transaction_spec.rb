include SecQuery
require 'spec_helper'

describe SecQuery::Filing do
  context "Owner" do
    describe "Transactions", vcr: { cassette_name: "Steve Jobs"} do
      let(:query){{
       name: "JOBS STEVEN P", :cik => "0001007844",
        transactions:[
          {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares:120000.0},
          {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
          {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
          {filing_number: "0001181431-07-052839", reporting_owner: "APPLE INC", shares: 40000.0},
          {filing_number: "0001181431-06-028746", reporting_owner: "WALT DISNEY CO/", shares: 138000004.0},
          {filing_number: "0001356184-06-000008", reporting_owner: "PIXAR \\CA\\", shares: 60000002.0},
          {filing_number: "0001181431-06-019230", reporting_owner: "APPLE COMPUTER INC", shares: 4573553.0},
          {filing_number: "0001181431-06-028747", reporting_owner: "WALT DISNEY CO/", shares: 0.0}
        ]
      }}

      let(:entity) {SecQuery::Entity.find(query[:cik])}
      
      # it "should respond to transactions" do
      #   entity.should respond_to(:transactions)
      #   entity.filings.should be_kind_of(Array)
      # end
          
      # it "should be valid transaction" do
      #   entity.transactions.first.inspect
      #   #is_valid_filing?(entity.filings.first)
      # end
      #     
      # it "should respond to content" do
      #   entity.filings.first.should respond_to(:content)
      #   puts entity.filings.first.content
      # end
    end
  end
end