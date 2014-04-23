include SecQuery
require 'spec_helper'

# Note: Shared Methods are available in spec_helper.rb

describe SecQuery::Entity do

  describe "Company Queries", vcr: { cassette_name: "aapl"} do

    let(:query){{name: "APPLE INC", sic: "3571", symbol: "aapl", cik:"0000320193"}}
    
    [:symbol, :cik, :name].each do |key|
      context "when quering by #{key}" do
        describe "as hash" do

          let(:entity){ SecQuery::Entity.find({ key => query[key] }) }

          it "should be valid" do
            is_valid?(entity)
          end

          it "should have a valid mailing address" do
            is_valid_address?(entity.mailing_address)
          end

          it "should have a valid business address" do
            is_valid_address?(entity.business_address)
          end
        end

        describe "as string" do
          it "should be valid" do
            entity = SecQuery::Entity.find(query[key])
            is_valid?(entity)
          end
        end
      end
    end
  end
  
  describe "People Queries", vcr: { cassette_name: "Steve Jobs"} do
  
    let(:query){ { name: "JOBS STEVEN P", :cik => "0001007844" } }

    [:cik, :name].each do |key|
      context "when quering by #{key}" do
        describe "as hash" do

          let(:entity){ SecQuery::Entity.find({ key => query[key] }) }

          it "should be valid" do
            is_valid?(entity)
          end

          it "should have a valid mailing address" do
            is_valid_address?(entity.mailing_address)
          end

          it "should have a valid business address" do
            is_valid_address?(entity.business_address)
          end
        end

        describe "as string" do
          it "should be valid" do
            entity = SecQuery::Entity.find(query[key])
            is_valid?(entity)
          end
        end
      end
    end
  end
end
