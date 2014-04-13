# encoding: UTF-8

module SecQuery
  # => SecQuery::Relationship
  # Relationships are Owner / Issuer Relationships between Entities,
  # forged by Transactions.
  class Relationship
    COLUMNS = :name, :position, :cik
    attr_accessor(*COLUMNS, :date)

    def initialize(relationship)
      COLUMNS.each do |column|
        instance_variable_set("@#{ column }", relationship[column])
      end
      date = relationship[:date].split('-')
      @date = Time.utc(date[0], date[1], date[2].to_i)
    end

    def self.find(entity)
      @relationships = []

      if entity[:doc]
        doc = entity[:doc]
      elsif entity[:cik]
        doc = Entity.document(entity[:cik])[0]
      end

      type = 'Ownership Reports for Issuers:'
      lines = doc.search('//table').search('//td').search("b[text()*='"+type+"']")
      if lines.empty?
        type = 'Ownership Reports from:'
        lines = doc.search('//table').search('//td').search("b[text()*='"+type+"']")
      end

      return false if lines.empty?

      relationship = {}
      lines = lines[0].parent.search('//table')[0].search('//tr')
      lines.each do |line|
        link = line.search('//a')[0]
        if link.innerHTML != 'Owner' && link.innerHTML != 'Issuer'
          relationship[:name] = link.innerHTML
          relationship[:cik] = line.search('//td')[1].search('//a').innerHTML
          relationship[:date] = line.search('//td')[2].innerHTML
          relationship[:position] = line.search('//td')[3].innerHTML
          @relationships << Relationship.new(relationship)
        end
      end
      @relationships
    end

    def self.print(relationships)
      if relationships
        puts "\n\t#{ relationships[1] }\n"
        printf("\t%-30s %-10s %-40s %-10s\n\n",
               'Entity',
               'CIK',
               'Position',
               'Date')
        issuer[:relationships].each do |relationship|
          printf("\t%-30s %-10s %-40s %-10s\n",
                 relationship.name,
                 relationship.cik,
                 relationship.position,
                 relationship.date)
        end
      else
        puts 'No relationships'
      end
    end
  end
end
