# sec_query

A ruby gem for searching and retrieving data from the Security and Exchange Commission's Edgar web system.

Look-up an Entity - person or company - by Central Index Key (CIK), stock symbol, company name or person (by first and last name).

Additionally retrieve some, or all, Relationships, Transactions and Filings as recorded by the SEC.

## Installation

To install the 'sec_query' Ruby Gem run the following command at the terminal prompt.

`gem install sec_query`

For an example of what type of information 'sec_query' can retrieve, run the following command:

`bundle exec rspec spec`

If running 'sec_query' from the command prompt in irb:

`irb -rubygems`

`require "sec_query"`

## Functionality

### FIND COMPANY:

#### By Stock Symbol:

`SecQuery::Entity.find("aapl")`

Or:

`SecQuery::Entity.find({:symbol=> "aapl"})`

#### By Name:

`SecQuery::Entity.find("Apple, Inc.")`

Or:

`SecQuery::Entity.find({:name=> "Apple, Inc."})`

#### By Central Index Key, CIK:

`SecQuery::Entity.find( "0000320193")`

Or: 

`SecQuery::Entity.find({:cik=> "0000320193"})`

#### FIND PERSON:

By First, Middle and Last Name.

`SecQuery::Entity.find({:first=> "Steve", :middle=> "P", :last=> "Jobs"})`

Middle initial or name is optional, but helps when there are multiple results for First and Last Name.

### RELATIONSHIPS, TRANSACTIONS, FILINGS

To return everything - All Relationships, Transactions and Filings - that the SEC Edgar system has stored on a company or person, do any of the following commands (They all do the same thing.):

`SecQuery::Entity.find("AAPL",  true)`

`SecQuery::Entity.find("AAPL",  true, true, true)`

`SecQuery::Entity.find("AAPL", {:relationships=> true, :transactions=> true, :filings=>true})`

`SecQuery::Entity.find("AAPL", :relationships=> true, :transactions=> true, :filings=>true)`

`SecQuery::Entity.find("AAPL", :relationships=> true, :transactions=> {:start=> 0, :count=> 80}, :filings=>{:start=> 0, :count=> 80})`

You may also limit either the transactions or filings by adding the :limit to the transaction or filing arguements.

For example,

`SecQuery::Entity.find("AAPL", :relationships=> true, :transactions=> {:start=> 0, :count=>20, :limit=> 20}, :filings=>{:start=> 0, :count=> 20, :limit=> 20})`

The above query will only return the last 20 transactions and filings.  This is helpful when querying companies that may have thousands or tens of thousands of transactions or filings.

## Classes

This gem contains four classes - Entity, Relationship, Transaction and Filing.  Each Class contains the listed fields. (Everything I could parse out of the query results.)

* Entity

`:first, :middle, :last, :name, :symbol, :cik, :url, :type, :sic, :location, :state_of_inc, :formerly, :mailing_address, :business_address, :relationships, :transactions, :filings`

* Relationship

`:name, :position, :date, :cik`

* Transaction

`:filing_number, :code, :date, :reporting_owner, :form, :type, :modes, :shares, :price, :owned, :number, :owner_cik, :security_name, :deemed, :exercise, :nature, :derivative, :underlying_1, :exercised,	:underlying_2, :expires, :underlying_3`

* Filing

`:cik, :title, :summary, :link, :term, :date, :file_id`

## To Whom It May Concern at the SEC

Over the last decade, I have gotten to know Edgar quite extensively and I have grown quite fond of it and the information it contains. So it is with my upmost respect that I make the following suggestions:

* Edgar is in dire need of a proper, published RESTful API.
* Edgar needs to be able to return XML or JSON  for any API query.
* Edgar's search engine is atrocious; Rigid to the point of being almost unusable.
* Edgar only goes back as far as 1993, and in most cases, only provides extensive information after 2000.

It is my humble opinion that these four issues are limiting the effectiveness of Edgar and the SEC in general.  The information the SEC contains is vitally important to National Security and the stability of the American Economy and the World.  It is time to  make all information available and accessible.

## License

Copyright (c) 2011 Ty Rauber

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
