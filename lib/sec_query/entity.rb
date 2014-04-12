# encoding: UTF-8

module SecQuery
  # => SecQuery::Entity
  # SecQuery::Entity is the root class which is responsible for requesting,
  # parsing and initializing SecQuery::Entity intances from SEC Edgar.
  class Entity
    attr_accessor :cik, :name, :mailing_address, :business_address,
                  :company_info

    def initialize(company_info)
      @company_info = Hashie::Mash.new(company_info)
      @cik = @company_info.cik
      @name = @company_info.conformed_name
      @company_info.addresses.address.each do |address|
        instance_variable_set "@#{address.type}_address", address
      end
    end

    def filings
      Filing.find(@cik)
    end

    def transactions
      Transaction.find(@cik)
    end

    def self.query(url)
      RestClient.get(url) do |response, request, result, &block|
        case response.code
        when 200
          return response
        else
          response.return!(request, result, &block)
        end
      end
    end

    def self.format_args(args)
      if args[:symbol]
        string = "CIK=#{args[:symbol]}"
      elsif args[:cik]
        string = "CIK=#{args[:cik]}"
      elsif args[:first] && args[:last]
        string = "company=#{args[:last]} #{args[:first]}"
      elsif args[:name]
        string = "company=#{args[:name].gsub(/[(,?!\''"":.)]/, '')}"
      end
      string.to_s.gsub(' ', '+')
    end

    def self.url(params)
      browse_edgar = 'http://www.sec.gov/cgi-bin/browse-edgar?'
      "#{browse_edgar}#{params}&action=getcompany"
    end

    def self.find(args)
      url = url(format_args(validate_args(args)))
      response = query("#{url}&output=atom")
      document = Nokogiri::HTML(response)
      company_info = parse(document)
      if company_info
        return Entity.new(company_info)
      else
        return nil
      end
    end

    def self.parse(document)
      if document.xpath('//feed/company-info').to_s.length > 0
        data = document.xpath('//feed/company-info').to_s
        company_info = Crack::XML.parse(data)['company_info']
      elsif document.xpath('//feed/entry/content/company-info').to_s.length > 0
        data = document.xpath('//content/company-info').to_s
        company_info = Crack::XML.parse(data)['company_info']
      else
        company_info = false
      end
      company_info
    end
  end
end
