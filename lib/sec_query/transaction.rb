module SecQuery
    class Transaction

        attr_accessor :filing_number, :code, :date, :reporting_owner, :form, :type, :modes, :shares, :price, :owned, :number, :owner_cik, :security_name, :deemed, :exercise, :nature, :derivative, :underlying_1, :exercised,	:underlying_2, :expires, :underlying_3
    
        def initialize(transaction)
            @filing_number = transaction[:form].split("/")[-2][0..19]
            @code = transaction[:code]
            if transaction[:date] != nil and transaction[:date] != "-"
                date = transaction[:date].split("-")
                @date = Time.utc(date[0],date[1],date[2])
            end
            @reporting_owner = transaction[:reporting_owner]
            @form = transaction[:form]
            @type = transaction[:type]
            @modes = transaction[:modes]
            @shares = transaction[:shares].to_f
            @price = transaction[:price].gsub("$", "").to_f
            @owned = transaction[:owned].to_f
            @number = transaction[:number].to_i
            @owner_cik = transaction[:owner_cik]
            @security_name = transaction[:security_name]
            @deemed = transaction[:deemed]
            @exercise = transaction[:exercise]
            @nature = transaction[:nature]
            @derivative = transaction[:derivative]
            @underlying_1 = transaction[:underlying_1].to_f
            @exercised = transaction[:exercised]
            @underlying_2 = transaction[:underlying_2].to_f
            if transaction[:expires] != nil;
                expires = transaction[:expires].split("-")
                @expires = Time.utc(expires[0],expires[1],expires[2].to_i)
            end
            @underlying_3 = transaction[:underlying_3].to_f
        end        
    
        def self.find(entity, start, count, limit)

            if start == nil; start = 0; end
            if count == nil; count = 80; end
            url = "http://www.sec.gov/cgi-bin/own-disp?action=get"+entity[:type]+"&CIK="+entity[:cik]+"&start="+start.to_s+"&count="+count.to_s
            response = Entity.query(url)
            doc = Hpricot(response)
            trans = doc.search("//td[@width='40%']")[0].parent.parent.search("//tr")
            i= start;
            query_more = false;
            for tran in trans
                td = tran.search("//td")
                if td[2] != nil and td[1].innerHTML != "Exercise"
                        query_more = true;
                        if !td[0].empty?
                        transaction={}
                        transaction[:code] = td[0].innerHTML;
                        transaction[:date] = td[1].innerHTML;
                        transaction[:reporting_owner] = td[2].innerHTML;
                        transaction[:form] = td[3].innerHTML;
                        transaction[:type] = td[4].innerHTML;
                        transaction[:modes] = td[5].innerHTML;
                        transaction[:shares] = td[6].innerHTML;
                        transaction[:price] = td[7].innerHTML;
                        transaction[:owned] = td[8].innerHTML;
                        transaction[:number] = td[9].innerHTML;
                        transaction[:owner_cik] = td[10].innerHTML;
                        transaction[:security_name] = td[11].innerHTML;
                        transaction[:deemed] = td[12].innerHTML;
                        if trans[i+1]; n_td = trans[i+1].search("//td"); end
                        if n_td != nil and n_td.count ==7 and n_td[0].innerHTML.empty?                         
                            transaction[:exercise] = n_td[1].innerHTML;
                            transaction[:nature] = n_td[2].innerHTML;
                            transaction[:derivative] = n_td[3].innerHTML;
                            transaction[:underlying_1] = n_td[4].innerHTML;
                            transaction[:exercised] = n_td[5].innerHTML;
                            transaction[:underlying_2] = n_td[6].innerHTML;
                            transaction[:expires] = n_td[7].innerHTML;
                            transaction[:underlying_3] =n_td[8].innerHTML;
                        end
                         entity[:transactions] << Transaction.new(transaction)
                    end
                end
                i=i+1 
            end
            if query_more and limit == nil || query_more and !limit
                Transaction.find(entity, start+count, count, limit);
            else
                return entity
            end
        end
    end
end
