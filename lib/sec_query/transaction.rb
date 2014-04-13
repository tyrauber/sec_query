# encoding: UTF-8

module SecQuery
  # => SecQuery::Transactions
  # SecQuery filings for any given SecQuery::Entity instance.
  class Transaction
    STR_COLUMNS = :code, :form, :type, :modes, :owner_cik, :security_name,
                  :deemed, :exercise, :nature, :derivative, :exercised,
                  :reporting_owner

    FLOAT_COLUMNS = :shares, :owned, :underlying_1, :underlying_2,
                    :underlying_3

    attr_accessor(*STR_COLUMNS, *FLOAT_COLUMNS, :filing_number, :date, :price,
                  :owned, :number, :expires)

    def initialize(transaction)
      @number = transaction[:number].to_i
      @price = transaction[:price].gsub('$', '').to_f
      @filing_number = transaction[:form].split('/')[-2][0..19]
      setup_columns(transaction)
      setup_date(transaction)
      setup_expires(transaction)
    end

    def setup_columns(transaction)
      STR_COLUMNS.each do |column|
        instance_variable_set("@#{ column }", transaction[column])
      end
      FLOAT_COLUMNS.each do |column|
        instance_variable_set("@#{ column }", transaction[column].to_f)
      end
    end

    def setup_transaction_date(transaction)
      if transaction[:date] && transaction[:date] != '-'
        date = transaction[:date].split('-')
        @date = Time.utc(date[0], date[1], date[2])
      end
    end

    def setup_expires(transaction)
      if transaction[:expires]
        expires = transaction[:expires].split('-')
        @expires = Time.utc(expires[0], expires[1], expires[2].to_i)
      end
    end

    def self.find(entity, start, count, limit)
      start ||= 0
      count ||= 80
      url = "http://www.sec.gov/cgi-bin/own-disp?action=get#{entity[:type]}&CIK=#{entity[:cik]}&start=#{start}&count=#{count}"
      response = Entity.query(url)
      doc = Hpricot(response)
      trans = doc.search("//td[@width='40%']")[0].parent.parent.search('//tr')
      i = start
      query_more = false
      trans.each do |tran|
        td = tran.search('//td')
        if td[2] && td[1].innerHTML != 'Exercise'
          query_more = true
          unless td[0].empty?
            transaction = {}
            transaction[:code] = td[0].innerHTML
            transaction[:date] = td[1].innerHTML
            transaction[:reporting_owner] = td[2].innerHTML
            transaction[:form] = td[3].innerHTML
            transaction[:type] = td[4].innerHTML
            transaction[:modes] = td[5].innerHTML
            transaction[:shares] = td[6].innerHTML
            transaction[:price] = td[7].innerHTML
            transaction[:owned] = td[8].innerHTML
            transaction[:number] = td[9].innerHTML
            transaction[:owner_cik] = td[10].innerHTML
            transaction[:security_name] = td[11].innerHTML
            transaction[:deemed] = td[12].innerHTML
            n_td = trans[i + 1].search('//td') if trans[i + 1]
            if n_td && n_td.count == 7 && n_td[0].innerHTML.empty?
              transaction[:exercise] = n_td[1].innerHTML
              transaction[:nature] = n_td[2].innerHTML
              transaction[:derivative] = n_td[3].innerHTML
              transaction[:underlying_1] = n_td[4].innerHTML
              transaction[:exercised] = n_td[5].innerHTML
              transaction[:underlying_2] = n_td[6].innerHTML
              transaction[:expires] = n_td[7].innerHTML
              transaction[:underlying_3] = n_td[8].innerHTML
            end
            entity[:transactions] << Transaction.new(transaction)
          end
        end
        i += 1
      end

      if (query_more && limit.nil?) || (query_more && !limit)
        Transaction.find(entity, start + count, count, limit)
      else
        return entity
      end
    end
  end
end
