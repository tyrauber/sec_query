# encoding: UTF-8

module SecQuery
  # => SecQuery::Filing
  # SecQuery::Filing requests and parses filings for any given SecQuery::Entity
  class Filing
    COLUMNS = [:cik, :title, :summary, :link, :term, :date, :file_id]

    attr_accessor(*COLUMNS)

    def initialize(filing)
      COLUMNS.each do |column|
        instance_variable_set("@#{ column }", filing[column])
      end
    end

    def detail
      @detail ||= FilingDetail.fetch(@link)
    end

    def self.fetch(uri, &blk)
      open(uri) do |rss|
        parse_rss(rss, &blk)
      end
    end

    def self.recent(options = {}, &blk)
      start = options.fetch(:start, 0)
      count = options.fetch(:count, 100)
      limit = options.fetch(:limit, 100)
      limited_count = [limit - start, count].min
      fetch(uri_for_recent(start, limited_count), &blk)
      start += count
      return if start >= limit
      recent({ start: start, count: count, limit: limit }, &blk)
    rescue OpenURI::HTTPError
      return
    end

    def self.for_cik(cik, options = {}, &blk)
      start = options.fetch(:start, 0)
      count = options.fetch(:count, 100)
      limit = options.fetch(:limit, 100)
      fetch(uri_for_cik(cik, start, count), &blk)
      start += count
      return if start >= limit
      for_cik(cik, { start: start, count: count, limit: limit }, &blk)
    rescue OpenURI::HTTPError
      return
    end

    def self.for_date(date, &blk)
      open(SecURI.for_date(date).to_s) do |file|
        filings_for_index(file.read).each(&blk)
      end
    rescue OpenURI::HTTPError
      return
    end

    def self.filings_for_index(index)
      [].tap do |filings|
        content_section = false
        index.each_line do |row|
          content_section = true if row.include?('-------------')
          next if !content_section || row.include?('------------')
          filing = filing_for_index_row(row)
          filings << filing unless filing.nil?
        end
      end
    end

    def self.filing_for_index_row(row)
      data = row.split(/   /).reject(&:blank?).map(&:strip)
      data = row.split(/  /).reject(&:blank?).map(&:strip) if data.count == 4
      return nil unless data[0] and data[1] and data[2] and data[3] and data[4]
      data.delete_at(1) if data[1][0] == '/'
      return nil unless Regexp.new(/\d{8}/).match(data[3])
      return nil if data[4] == nil
      unless data[4][0..3] == 'http'
        data[4] = "https://www.sec.gov/Archives/#{ data[4] }"
      end
      begin
        Date.parse(data[3])
      rescue ArgumentError
        return nil
      end
      Filing.new(
        term: data[1],
        cik: data[2],
        date: Date.parse(data[3]),
        link: data[4]
      )
    end

    def self.uri_for_recent(start = 0, count = 100)
      SecURI.browse_edgar_uri(
        action: :getcurrent,
        owner: :include,
        output: :atom,
        start: start,
        count: count
      )
    end

    def self.uri_for_cik(cik, start = 0, count = 100)
      SecURI.browse_edgar_uri(
        action: :getcompany,
        owner: :include,
        output: :atom,
        start: start,
        count: count,
        CIK: cik
      )
    end

    def self.parse_rss(rss, &blk)
      feed = RSS::Parser.parse(rss, false)
      feed.entries.each do |entry|
        filing = Filing.new(
          cik: entry.title.content.match(/\((\w{10})\)/)[1],
          file_id: entry.id.content.split('=').last,
          term:  entry.category.term,
          title: entry.title.content,
          summary: entry.summary.content,
          date: DateTime.parse(entry.updated.content.to_s),
          link: entry.link.href.gsub('-index.htm', '.txt')
        )
        blk.call(filing)
      end
    end

    def self.find(cik, start = 0, count = 80, args={})
      temp = {}
      temp[:url] = SecURI.browse_edgar_uri({cik: cik})
      temp[:url][:action] = :getcompany
      temp[:url][:start] = start
      temp[:url][:count] = count
      args.each {|k,v| temp[:url][k]=v }
      
      response = Entity.query(temp[:url].output_atom.to_s)
      document = Nokogiri::HTML(response)
      parse(cik, document)
    end

    def self.last(cik, args = {})
      find(cik, 0, 1, args)&.first
    end

    def self.parse(cik, document)
      filings = []
      if document.xpath('//content').to_s.length > 0
        document.xpath('//content').each do |e|
          if e.xpath('//content/accession-nunber').to_s.length > 0
            content = Hash.from_xml(e.to_s)['content']
            content[:cik] = cik
            content[:file_id] = content.delete('accession_nunber')
            content[:date] = content.delete('filing_date')
            content[:link] = content.delete('filing_href')
            content[:term] = content.delete('filing_type')
            content[:title] = content.delete('form_name')
            filings << Filing.new(content)
          end
        end
      end
      filings
    end

    def content(&error_blk)
      @content ||= RestClient.get(self.link)
    rescue RestClient::ResourceNotFound => e
      puts "404 Resource Not Found: Bad link #{ self.link }"
      if block_given?
        error_blk.call(e, self)
      else
        raise e
      end
    end
  end
end
