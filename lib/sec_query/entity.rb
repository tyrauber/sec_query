# encoding: UTF-8

module SecQuery
  # => SecQuery::Entity
  # SecQuery::Entity is the root class which is responsible for requesting,
  # parsing and initializing SecQuery::Entity intances from SEC Edgar.
  class Entity
    COLUMNS = [:cik, :name, :mailing_address, :business_address, :company_info,
      :assigned_sic, :assigned_sic_desc, :assigned_sic_href, :assitant_director, :cik, :cik_href,
      :formerly_name, :state_location, :state_location_href, :state_of_incorporation]
    attr_accessor(*COLUMNS)

    def initialize(entity)
      entity = Hashie::Mash.new(entity)
      entity[:name] = entity.delete(:conformed_name)
      entity.addresses.address.each do |address|
        entity["#{address.type}_address".to_sym] = address
      end
      COLUMNS.each do |column|
        instance_variable_set("@#{ column }", entity[column])
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

    def self.find(entity_args)
      temp = {}
      temp[:url] = SecURI.browse_edgar_uri(entity_args)
      temp[:url][:action] = :getcompany
      response = query(temp[:url].output_atom.to_s)
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
