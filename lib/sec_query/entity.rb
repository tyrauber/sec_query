# encoding: UTF-8

module SecQuery
  # => SecQuery::Entity
  # SecQuery::Entity is the root class which is responsible for requesting,
  # parsing and initializing SecQuery::Entity intances from SEC Edgar.
  class Entity
    COLUMNS = [:first, :middle, :last, :name, :symbol, :cik, :url, :type, :sic,
               :location, :state_of_inc, :formerly, :mailing_address,
               :business_address, :relationships, :transactions, :filings]

    attr_accessor(*COLUMNS)

    def initialize(entity)
      COLUMNS.each do |column|
        instance_variable_set("@#{ column }", entity[column])
      end
    end

    def self.find(entity_args, *options)
      temp = {}
      temp[:url] = SecURI.browse_edgar_uri(entity_args)
      temp[:url][:action] = :getcompany
      temp[:cik] = Entity.cik(temp[:url], entity_args)

      if !temp[:cik] || temp[:cik] == ''
        puts "No Entity found for query: #{ temp[:url] }"
        return false
      end

      ### Get Document and Entity Type
      doc = Entity.document(temp[:cik])
      temp = Entity.parse_document(temp, doc)

      ### Get Additional Arguments and Query Additional Details
      unless options.empty?
        temp[:transactions] = []
        temp[:filings] = []
        options = Entity.options(temp, options)
        temp = Entity.details(temp, options)
      end

      ###  Return entity Object
      @entity = Entity.new(temp)
      @entity
    end

    def self.query(url)
      RestClient.get(url.to_s) do |response, request, result, &block|
        case response.code
        when 200
          return response
        else
          response.return!(request, result, &block)
        end
      end
    end

    def self.cik(url, entity)
      response = Entity.query(url.output_atom.to_s)
      doc = Hpricot::XML(response)
      data = doc.search('//feed/title')[0]
      if data.inner_text == 'EDGAR Search Results'
        tbl = doc.search("//span[@class='companyMatch']")
        if tbl && tbl.innerHTML != ''
          tbl = tbl[0].parent.search('table')[0].search('tr')
          tbl.each do |tr|
            td = tr.search('td')
            if td[1] && entity[:middle] && td[1].innerHTML.downcase == ("#{entity[:last]} #{entity[:first]} #{entity[:middle]}").downcase || td[1] && td[1].innerHTML.downcase == ("#{ entity[:last] } #{ entity[:first] }").downcase
              cik = td[0].search('a').innerHTML
              return cik
            end
          end
        else
          return false
        end
      else
        cik = data.inner_text.scan(/\(([^)]+)\)/).to_s
        cik = cik.gsub('[["', '').gsub('"]]', '')
        return cik
      end
    end

    def self.document(cik)
      url = SecURI.ownership_display_uri(action: :getissuer, CIK: cik)
      response = query(url)
      doc = Hpricot(response)
      text = 'Ownership Reports from:'
      type = 'issuer'
      entity = doc.search('//table').search('//td').search("b[text()*='#{text}']")
      if entity.empty?
        url = SecURI.ownership_display_uri(action: :getowner, CIK: cik)
        response = query(url)
        doc = Hpricot(response)
        text = 'Ownership Reports for entitys:'
        type = 'owner'
        entity = doc.search('//table').search('//td').search("b[text()*='#{text}']")
      end
      [doc, type]
    end

    def self.parse_document(temp, doc)
      info = Entity.info(doc[0])
      temp[:type] = doc[1]
      temp[:name] = info[:name]
      temp[:location] = info[:location]
      temp[:sic] = info[:sic]
      temp[:state_of_inc] = info[:state_of_inc]
      temp[:formerly] = info[:formerly]

      ### Get Mailing Address
      temp[:mailing_address] = Entity.mailing_address(doc[0])

      ### Get Business Address
      temp[:business_address] = Entity.business_address(doc[0])

      temp
    end

    def self.info(doc)
      info = {}
      lines = doc.search("//td[@bgcolor='#E6E6E6']")[0].parent.parent.search('//tr')
      td = lines[0].search('//td//b').innerHTML
      info[:name] = td.gsub(td.scan(/\(([^)]+)\)/).to_s, '').gsub('()', '').gsub('\n', '')
      lines = lines[1].search('//table')[0].search('//tr//td')

      if lines[0].search('a')[0]
        info[:sic] = lines[0].search('a')[0].innerHTML
      end

      if lines[0].search('a')[1]
        info[:location] = lines[0].search('a')[1].innerHTML
      end

      if lines[0].search('b')[0] && lines[0].search('b')[0].innerHTML.squeeze(' ') != ' '
        info[:state_of_inc] = lines[0].search('b')[0].innerHTML
      end

      if lines[1] && lines[1].search('font')
        info[:formerly] = lines[1].search('font').innerHTML
          .gsub('formerly: ', '').gsub('<br />', '').gsub('\n', '; ')
      end

      info
    end

    def self.business_address(doc)
      addie = doc.search('//table').search('//td')
        .search("b[text()*='Business Address']")
      if !addie.empty?
        business_address = addie[0].parent.innerHTML
          .gsub('<b class="blue">Business Address</b>', '').gsub('<br />', ' ')
        return business_address
      else
        return false
      end
    end

    def self.mailing_address(doc)
      addie = doc.search('//table').search('//td')
        .search("b[text()*='Mailing Address']")
      if !addie.empty?
        mailing_address = addie[0].parent.innerHTML
          .gsub('<b class="blue">Mailing Address</b>', '').gsub('<br />', ' ')
        return mailing_address
      else
        return false
      end
    end

    def self.options(temp, options)
      args = {}
      if options.is_a?(Array) && options.length == 1 && options[0] == true
        args[:relationships] = true
        args[:transactions] = true
        args[:filings] = true
      elsif options.is_a?(Array) && options.length > 1
        args[:relationships] = options[0]
        args[:transactions] = options[1]
        args[:filings] = options[2]
      elsif options[0].is_a?(Hash)
        args[:relationships] = options[0][:relationships]
        args[:transactions] = options[0][:transactions]
        args[:filings] = options[0][:filings]
      end
      args
    end

    def self.details(temp, options)
      ## Get Relationships for entity
      if options[:relationships] == true
        relationships = Relationship.find(temp)
        temp[:relationships] = relationships
      end

      ## Get Transactions for entity
      if options[:transactions] && options[:transactions].is_a?(Hash)
        temp = Transaction.find(
          temp,
          options[:transactions][:start],
          options[:transactions][:count],
          options[:transactions][:limit])
      elsif options[:transactions] && options[:transactions] == true
        temp = Transaction.find(temp, nil, nil, nil)
      end

      ## Get Filings for entity
      if options[:filings] && options[:filings].is_a?(Hash)
        temp = Filing.find(
          temp,
          options[:filings][:start],
          options[:filings][:count],
          options[:filings][:limit])
      elsif options[:filings] && options[:filings] == true
        temp = Filing.find(temp, nil, nil, nil)
      end

      temp
    end
  end
end
