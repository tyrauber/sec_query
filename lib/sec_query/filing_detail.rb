# encoding: UTF-8

module SecQuery
  # => SecQuery::FilingDetail
  # SecQuery::FilingDetail requests and parses Filing Detail for any given SecQuery::Filing
  class FilingDetail
    COLUMNS = [:link, :filing_date, :accepted_date, :period_of_report, :sec_access_number, :document_count, :format_files, :data_files]

    attr_accessor(*COLUMNS)

    def initialize(filing_detail)
      COLUMNS.each do |column|
        instance_variable_set("@#{ column }", filing_detail[column])
      end
    end

    def self.fetch(uri)
      response = RestClient::Request.execute(method: :get, url: uri.to_s.gsub('http:', 'https:'), timeout: 10)
      document = Nokogiri::HTML(response.body)
      filing_date = document.xpath('//*[@id="formDiv"]/div[2]/div[1]/div[2]').text
      accepted_date = document.xpath('//*[@id="formDiv"]/div[2]/div[1]/div[4]').text
      period_of_report = document.xpath('//*[@id="formDiv"]/div[2]/div[2]/div[2]').text
      sec_access_number = document.xpath('//*[@id="secNum"]/text()').text.strip
      document_count = document.xpath('//*[@id="formDiv"]/div[2]/div[1]/div[6]').text.to_i
      format_files_table = document.xpath("//table[@summary='Document Format Files']")
      data_files_table = document.xpath("//table[@summary='Data Files']")

      format_files = (parsed = parse_files(format_files_table)) && (parsed || [])
      data_files = (parsed = parse_files(data_files_table)) && (parsed || [])

      new({uri: uri,
           filing_date: filing_date,
           accepted_date: accepted_date,
           period_of_report: period_of_report,
           sec_access_number: sec_access_number,
           document_count: document_count,
           format_files: format_files,
           data_files: data_files})
    end

    def self.parse_files(format_files_table)
      # get table headers
      headers = []
      format_files_table.xpath('//th').each do |th|
        headers << th.text
      end

      # get table rows
      rows = []
      format_files_table.xpath('//tr').each_with_index do |row, i|
        rows[i] = {}
        row.xpath('td').each_with_index do |td, j|
          if td.children.first && td.children.first.name == 'a'
            relative_url = td.children.first.attributes.first[1].value
            rows[i][headers[j]] = {
                'link' => "https://www.sec.gov#{relative_url}",
                'text' => td.text.gsub(/\A\p{Space}*/, '')
            }
          else
            rows[i][headers[j]] = td.text.gsub(/\A\p{Space}*/, '')
          end
        end
      end

      rows.reject(&:empty?)
    end
  end
end
