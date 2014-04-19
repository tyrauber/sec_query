# encoding: UTF-8

module SecQuery
  # => SecQuery::Filing
  # SecQuery::Filing requests and parses filings for any given SecQuery::Entity
  class Filing
    COLUMNS = :cik, :title, :summary, :link, :term, :date, :file_id
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

    def self.find(entity, start, count, limit)
      start ||= 0
      count ||= 80
      url = uri_for_cik(entity[:cik], start, count)
      response = Entity.query(url)
      doc = Hpricot::XML(response)
      entries = doc.search(:entry)
      query_more = false
      entries.each do |entry|
        query_more = true
        filing = {}
        filing[:cik] = entity[:cik]
        filing[:title] = (entry/:title).innerHTML
        filing[:summary] = (entry/:summary).innerHTML
        filing[:link] =  (entry/:link)[0].get_attribute('href')
        filing[:term] = (entry/:category)[0].get_attribute('term')
        filing[:date] = (entry/:updated).innerHTML
        filing[:file_id] = (entry/:id).innerHTML.split('=').last
        entity[:filings] << Filing.new(filing)
      end
      if (query_more && limit.nil?) || (query_more && !limit)
        Filing.find(entity, start + count, count, limit)
      else
        return entity
      end
    end
  end
end
