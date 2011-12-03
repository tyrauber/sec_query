module SecQuery
    class Relationship
        
        ## Relationships are Owner / Issuer Relationships between Entities, forged by Transactions.
        
        attr_accessor :name, :position, :date, :cik
        def initialize(relationship)
            @cik = relationship[:cik];
            @name = relationship[:name];
            @position = relationship[:position];
            date = relationship[:date].split("-")
            @date = Time.utc(date[0],date[1],date[2].to_i)
        end
        
        
        def self.find(entity)
            @relationships =[]

            if entity[:doc] != nil
                doc = entity[:doc]
            elsif entity[:cik] != nil
                doc = Entity.document(entity[:cik])[0]
            end
            
            type = "Ownership Reports for Issuers:"
            lines = doc.search("//table").search("//td").search("b[text()*='"+type+"']")
            if lines.empty?
                type = "Ownership Reports from:"
                lines = doc.search("//table").search("//td").search("b[text()*='"+type+"']");
            end
            if !lines.empty?
                relationship = {}
                lines= lines[0].parent.search("//table")[0].search("//tr")
                for line in lines
                    link = line.search("//a")[0]
                    if link.innerHTML != "Owner" and link.innerHTML != "Issuer"
                        relationship[:name] = link.innerHTML;
                        relationship[:cik] =  line.search("//td")[1].search("//a").innerHTML
                        relationship[:date] = position = line.search("//td")[2].innerHTML
                        relationship[:position] = line.search("//td")[3].innerHTML
                        @relationship = Relationship.new(relationship)
                        @relationships << @relationship
                    
                    end
                end
                return @relationships
            else
                return false
            end
        end
        def self.print(relationships)
            if relationships
                puts "\n\t"+relationships[1]+"\n"
                printf("\t%-30s %-10s %-40s %-10s\n\n","Entity", "CIK", "Position", "Date")
                for relationship in issuer[:relationships]
                    printf("\t%-30s %-10s %-40s %-10s\n",relationship.name, relationship.cik, relationship.position, relationship.date)
                end
            else
                puts "No relationships"
            end
        end
    end
end
