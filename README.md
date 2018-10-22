# sec_query

A ruby gem for searching and retrieving data from the Security and Exchange Commission's Edgar web system.

Look-up an Entity - person or company - by Central Index Key (CIK), stock symbol, company name or person (by first and last name).

Additionally retrieve some, or all, Relationships, Transactions and Filings as recorded by the SEC.

## Note: 9/13/16, SEC.GOV embraces SSL!

On or before Septmember 13th, 2016, the SEC.gov updated their site to use SSL (Huzzah!). Version 1.2.0 addresses this change. All versions less than 1.2.0, will cease to function as expected. Update immediately.

## Installation

To install the 'sec_query' Ruby Gem run the following command at the terminal prompt.

`gem install sec_query`

For an example of what type of information 'sec_query' can retrieve, run the following command:

`bundle exec rspec spec`

If running 'sec_query' from the command prompt in irb:

`irb -rubygems`

`require "sec_query"`

## Functionality

### Entity:

An Sec::Entity instance contains the following attributes:

* cik
* name
* mailing_address
* business_adddress
* assigned_sic
* assigned_sic_desc
* assigned_sic_href
* assitant_director
* cik_href
* formerly_name
* state_location
* state_location_href
* state_of_incorporation

#### Class Methods

##### .find 

###### By Stock Symbol:

`SecQuery::Entity.find("aapl")`

Or:

`SecQuery::Entity.find({:symbol=> "aapl"})`

###### By Name:

`SecQuery::Entity.find("Apple, Inc.")`

Or:

`SecQuery::Entity.find({:name=> "Apple, Inc."})`

######  Central Index Key, CIK

`SecQuery::Entity.find( "0000320193")`

Or: 

`SecQuery::Entity.find({:cik=> "0000320193"})`

###### By First, Middle and Last Name:

By First, Middle and Last Name.

`SecQuery::Entity.find({:first=> "Steve", :middle=> "P", :last=> "Jobs"})`

Middle initial or name is optional, but helps when there are multiple results for First and Last Name.

#### Instance Methods

##### .filings

Returns a list of Sec::Filing instances for an Sec::Entity

### SecQuery::Filing

SecQuery::Filing instance may contains the following attributes:

* cik
* title
* symmary
* link
* term
* date
* file_id
* detail

#### Class Methods

##### .recent

Find recent filings:

```
filings = []
SecQuery::Filing.recent(start: 0, count: 10, limit: 10) do |filing|
  filings.push filing
end
```

Requires a block. Returns the most recent filings. Use start, count and limit to iterate through recent filings.

### SecQuery::FilingDetail
Represents the detail page for a given filing. 
Ex: [Filing Detail page](https://www.sec.gov/Archives/edgar/data/320193/000032019317000070/0000320193-17-000070-index.htm) of Apple's Annual Report from 2017

#### Instance Methods
* link
* filing_date
* accepted_date
* period_of_report
* sec_access_number
* document_count
* format_files
* data_files

#### Class Methods
##### .fetch
```
appl_10k_details_url = 'https://www.sec.gov/Archives/edgar/data/320193/000032019317000070/0000320193-17-000070-index.htm'
filing_detail = SecQuery::FilingDetail.fetch(appl_10k_details_url)
```

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
