module SecQuery
    class Filing
        attr_accessor :cik, :title, :summary, :link, :term, :date, :file_id
        def initialize(filing)
            @cik = filing[:cik]
            @title = filing[:title]
            @summary = filing[:summary]
            @link = filing[:link]
            @term = filing[:term]
            @date = filing[:date]
            @file_id = filing[:file_id]
        end
  
    
        def self.find(entity, start, count, limit)

            if start == nil; start = 0; end
            if count == nil; count = 80; end
            url ="http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK="+entity[:cik]+"&output=atom&count="+count.to_s+"&start="+start.to_s
            response = Entity.query(url)
            doc = Hpricot::XML(response)
            entries = doc.search(:entry);
            query_more = false;
            for entry in entries
                query_more = true;
                filing={}
                filing[:cik] = entity[:cik]
                filing[:title] = (entry/:title).innerHTML
                filing[:summary] = (entry/:summary).innerHTML
                filing[:link] =  (entry/:link)[0].get_attribute("href")
                filing[:term] = (entry/:category)[0].get_attribute("term")
                filing[:date] = (entry/:updated).innerHTML
                filing[:file_id] = (entry/:id).innerHTML.split("=").last

                entity[:filings] << Filing.new(filing)              
            end
            if query_more and limit == nil || query_more and !limit
                Filing.find(entity, start+count, count, limit);
            else
                return entity
            end
        end 
    end

end
