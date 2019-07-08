module SecQuery
  module Document
    class Form4
      attr_reader :type, :period_of_report, :subject_to_section_16

      def initialize(document)
        @document = document.is_a?(Hash) ? document : {}
        unless @document.empty?
          @type = @document['documenttype']
          @period_of_report = @document['periodofreport']
          @subject_to_section_16 = @document['notsubjecttosection16'].to_i == 0
        end
      end

      def to_h
        {
          'type' => type,
          'period_of_report' => period_of_report,
          'subject_to_section_16' => subject_to_section_16,
          'issuer' => issuer,
          'reporting_owner' => reporting_owner,
          'securities' => securities,
          'footnotes' => footnotes,
          'remarks' => remarks
        }
      end

      def issuer
        return @issuer if @issuer
        @issuer = {}
        @document['issuer'].each {|k,v| @issuer[k.gsub('issuer','')] = v }
        @issuer['trading_symbol'] = @issuer.delete('tradingsymbol')
        @issuer.any? ? @issuer : nil
      end

      def reporting_owner
        reporting_owners.first || {}
      end

      def owner_signature
        @document['ownersignature']
      end

      def owner_signature_name
        @document.dig('ownersignature', 'signaturename')
      end

      def owner_signature_date
        @document.dig('ownersignature', 'signaturedate')
      end

      def reporting_owners
        return @reporting_owners if @reporting_owners
        @reporting_owners = [@document.dig('reportingowner')].flatten.map do |doc_hsh|
          owner_hsh = {}
          owner_hsh['cik'] = doc_hsh.dig('reportingownerid', 'rptownercik')
          owner_hsh['name'] = doc_hsh.dig('reportingownerid', 'rptownername')

          if doc_hsh.dig('reportingowneraddress')
            owner_hsh['address'] = {}
            owner_hsh['address']['street1'] = doc_hsh.dig('reportingowneraddress', 'rptownerstreet1')
            owner_hsh['address']['street2'] = doc_hsh.dig('reportingowneraddress', 'rptownerstreet2')
            owner_hsh['address']['city'] = doc_hsh.dig('reportingowneraddress', 'rptownercity')
            owner_hsh['address']['state'] = doc_hsh.dig('reportingowneraddress', 'rptownerstate')
            owner_hsh['address']['zip_code'] = doc_hsh.dig('reportingowneraddress', 'rptownerzipcode')
            owner_hsh['address']['state_description'] = doc_hsh.dig('reportingowneraddress', 'rptownerstatedescription')
          end

          if doc_hsh.dig('reportingownerrelationship', 'isdirector')
            owner_hsh['is_director'] = doc_hsh.dig('reportingownerrelationship', 'isdirector').to_i == 1
          end

          if doc_hsh.dig('reportingownerrelationship', 'isofficer')
            owner_hsh['is_officer'] = doc_hsh.dig('reportingownerrelationship', 'isofficer').to_i == 1
          end

          if doc_hsh.dig('reportingownerrelationship', 'isother')
            owner_hsh['is_other'] = doc_hsh.dig('reportingownerrelationship', 'isother').to_i == 1
          end

          owner_hsh['other_text'] = doc_hsh.dig('reportingownerrelationship', 'othertext')
          owner_hsh['officer_title'] = doc_hsh.dig('reportingownerrelationship', 'officertitle')

          owner_hsh.any? ? owner_hsh : nil
        end.compact
      end

      def remarks
        return @remarks if @remarks
        @remarks = []
        if @document['remarks']
          # TO-DO: find example... Is this an array or string?
        end
        @remarks
      end

      def footnotes
        return @footnotes if @footnotes
        if @document.dig('footnotes', 'footnote')
          @footnotes = @document['footnotes'].flatten.reject{|x| x == 'footnote'}.flatten
        else
          @footnotes = []
        end
      end

      def securities
        return @securities if @securities
        @securities = []
        if @document.dig('nonderivativetable')
          [@document.dig('nonderivativetable', 'nonderivativetransaction')].flatten.each do |transaction|
            security = {}
            security['type'] = transaction.dig('securitytitle', 'value')
            footnote_id = transaction.dig('securitytitle', 'footnoteid', 'id')
            if footnote_id && footnotes.any?
              i = footnote_id.gsub('F','').to_i - 1
              security['type_footnote'] = footnotes[i] if footnotes.count > i
            end

            security['transaction_date'] = transaction.dig('transactiondate','value')

            security['coding'] = {}
            security['coding']['form_type'] = transaction.dig('transactioncoding','transactionformtype')
            security['coding']['code'] = transaction.dig('transactioncoding','transactioncode')
            security['coding']['equity_swap_involved'] = transaction.dig('transactioncoding','equityswapinvolved').to_i == 1

            if transaction['transactionamounts']
              security['amounts'] = {}
              security['amounts']['shares'] = (shares = transaction.dig('transactionamounts','transactionshares', 'value')) && shares&.to_i
              security['amounts']['price_per_share'] = (pps = transaction.dig('transactionamounts','transactionpricepershare', 'value')) && pps&.to_f
              security['amounts']['acquired_disposed_code'] = (adc = transaction.dig('transactionamounts','transactionacquireddisposedcode', 'value')) && adc

              footnote_id = transaction.dig('transactionamounts', 'transactionpricepershare', 'footnoteid', 'id')
              if footnote_id
                i = footnote_id.gsub('F','').to_i - 1
                security['price_per_share_footnote'] = footnotes[i] if footnotes.count > i
              end

              if transaction.dig('posttransactionamounts', 'sharesownedfollowingtransaction', 'value')
                security['post_transaction_amounts'] = {}
                security['post_transaction_amounts']['shares_owned'] = (value = transaction.dig('posttransactionamounts', 'sharesownedfollowingtransaction', 'value')) && value&.to_i
              end

              if transaction.dig('ownershipnature', 'directorindirectownership', 'value')
                security['ownership_nature'] = {'direct_or_indirect_ownership' => transaction.dig('ownershipnature', 'directorindirectownership', 'value') }
              end
            end
            @securities << security
          end
        end
        @securities
      end

      def self.fetch(uri)
        html = Nokogiri::HTML(open(uri))
        document = Hash.from_xml(html.xpath('//body//ownershipdocument').to_s)&.dig('ownershipdocument') || {}
        new(document)
      end
    end
  end
end
