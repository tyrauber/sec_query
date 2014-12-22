# encoding: UTF-8
module SecQuery
  # => SecQuery::Entity
  # SecQuery::Entity is the root class which is responsible for requesting,
  # parsing and initializing SecQuery::Entity intances from SEC Edgar.
  class Entity
    COLUMNS = [:cik, :name, :mailing_address, :business_address,
      :assigned_sic, :assigned_sic_desc, :assigned_sic_href, :assitant_director, :cik_href,
      :formerly_names, :state_location, :state_location_href, :state_of_incorporation]
    attr_accessor(*COLUMNS)

    def initialize(entity)
      COLUMNS.each do |column|
        instance_variable_set("@#{ column }", entity[column.to_s])
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
      xml = document.xpath("//feed/company-info")
      Entity.new(parse(xml))
    end

    def self.parse(xml)
      content = Hash.from_xml(xml.to_s)
      if content['company_info'].present?
        content = content['company_info']
        content['name'] = content.delete('conformed_name')
        if content['formerly_names'].present?
          content['formerly_names'] = content.delete('formerly_names')['names']
        end
        content['addresses']['address'].each do |address|
          content["#{address['type']}_address"] = address unless address.nil?
        end
        return content
      else
        return {}
      end
    end
  end
end
