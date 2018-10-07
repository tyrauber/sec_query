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
        return @reporting_owner if @reporting_owner
        @reporting_owner = {}
        @reporting_owner['cik'] = @document.dig('reportingowner', 'reportingownerid', 'rptownercik')
        @reporting_owner['name'] = @document.dig('reportingowner', 'reportingownerid', 'rptownername')

        if @document.dig('reportingowner', 'reportingowneraddress')
          @reporting_owner['address'] = {}
          @reporting_owner['address']['street1'] = @document.dig('reportingowner', 'reportingowneraddress', 'rptownerstreet1')
          @reporting_owner['address']['street2'] = @document.dig('reportingowner', 'reportingowneraddress', 'rptownerstreet2')
          @reporting_owner['address']['city'] = @document.dig('reportingowner', 'reportingowneraddress', 'rptownercity')
          @reporting_owner['address']['state'] = @document.dig('reportingowner', 'reportingowneraddress', 'rptownerstate')
          @reporting_owner['address']['zip_code'] = @document.dig('reportingowner', 'reportingowneraddress', 'rptownerzipcode')
          @reporting_owner['address']['state_description'] = @document.dig('reportingowner', 'reportingowneraddress', 'rptownerstatedescription')
        end

        if @document.dig('reportingowner', 'reportingownerrelationship', 'isdirector')
          @reporting_owner['is_director'] = @document.dig('reportingowner', 'reportingownerrelationship', 'isdirector').to_i == 1
        end

        if @document.dig('reportingowner', 'reportingownerrelationship', 'isofficer')
          @reporting_owner['is_officer'] = @document.dig('reportingowner', 'reportingownerrelationship', 'isofficer').to_i == 1
        end

        if @document.dig('reportingowner', 'reportingownerrelationship', 'isother')
          @reporting_owner['is_other'] = @document.dig('reportingowner', 'reportingownerrelationship', 'isother').to_i == 1
        end

        @reporting_owner['other_text'] = @document.dig('reportingowner', 'reportingownerrelationship', 'othertext')
        @reporting_owner['officer_title'] = @document.dig('reportingowner', 'reportingownerrelationship', 'officertitle')

        if @document.dig('ownersignature', 'signaturename')
          @reporting_owner['signature'] = {}
          @reporting_owner['signature']['name'] = @document.dig('ownersignature', 'signaturename')
          @reporting_owner['signature']['date'] = @document.dig('ownersignature', 'signaturedate')
        end

        @reporting_owner.any? ? @reporting_owner : nil
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
          @document.dig('nonderivativetable', 'nonderivativetransaction').each do |transaction|
            security = {}
            security['type'] = transaction.dig('securitytitle', 'value')
            footnote_id = @document.dig('nonderivativetable', 'nonderivativetransaction').first.dig('securitytitle', 'footnoteid', 'id')
            if footnote_id && footnotes.any?
              i = footnote_id.gsub('F','').to_i - 1
              security['type_footnote'] = footnotes[i] if footnotes.count > i
            end

            security['transaction_date'] = @document.dig('nonderivativetable', 'nonderivativetransaction').first.dig('transactiondate','value')

            security['coding'] = {}
            security['coding']['form_type'] = @document.dig('nonderivativetable', 'nonderivativetransaction').first.dig('transactioncoding','transactionformtype')
            security['coding']['code'] = @document.dig('nonderivativetable', 'nonderivativetransaction').first.dig('transactioncoding','transactioncode')
            security['coding']['equity_swap_involved'] = @document.dig('nonderivativetable', 'nonderivativetransaction').first.dig('transactioncoding','equityswapinvolved').to_i == 1

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
