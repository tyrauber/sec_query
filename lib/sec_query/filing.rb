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

    def self.find(cik, start = 0, count = 80)
      temp = {}
      temp[:url] = SecURI.browse_edgar_uri({cik: cik})
      temp[:url][:action] = :getcompany
      temp[:url][:start] = start
      temp[:url][:count] = count
      response = Entity.query(temp[:url].output_atom.to_s)
      document = Nokogiri::HTML(response)
      parse(cik, document)
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
  end
end
