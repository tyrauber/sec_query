# encoding: UTF-8

module SecQuery
  class Filing
    attr_accessor :cik, :accession_nunber, :act, :file_number, :file_number_href, :filing_date, :filing_href, :filing_type, :film_number, :form_name, :size, :type

    def initialize(cik, filing)
      @cik = cik
      filing.each do |key, value|
        instance_variable_set "@#{key}", value.to_s
      end
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
      fetch(uri_for_recent(start, count), &blk)
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
        filing = Filing.new({
          cik: entry.title.content.match(/\((\w{10})\)/)[1],
          file_id: entry.id.content.split('=').last,
          term:  entry.category.term,
          title: entry.title.content,
          summary: entry.summary.content,
          date: DateTime.parse(entry.updated.content.to_s),
          link: entry.link.href.gsub('-index.htm', '.txt')
        })
        blk.call(filing)
      end
    end

    def self.find(cik, start=0, count=80)
      url = "http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{cik}&count=#{count}&start=#{start}"
      response = Entity.query(url+"&output=atom")
      document = Nokogiri::HTML(response)
      filings = []
      if document.xpath('//content').to_s.length > 0
        document.xpath('//content').each do |e|
          if e.xpath('//content/accession-nunber').to_s.length > 0
            filings << Filing.new(cik, Crack::XML.parse(e.to_s)['content'])
          end
        end
      end
      return filings
    end
  end
end
