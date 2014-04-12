# encoding: UTF-8

module SecQuery
  class SecURI
    attr_accessor :host, :scheme, :path, :query_values

    def self.browse_edgar_uri(args = nil)
      build_with_path('/browse-edgar', args)
    end

    def self.ownership_display_uri(args = nil)
      build_with_path('/own-disp', args)
    end

    def self.build_with_path(path, args)
      instance = SecURI.new
      instance.path += path
      return instance if args.nil?
      options = send("handle_#{ args.class.to_s.underscore }_args", args)
      instance.query_values = options
      instance
    end

    def self.handle_string_args(string_arg)
      options = {}
      begin Float(string_arg)
        options[:CIK] = string_arg
      rescue
        if string_arg.length <= 4
          options[:CIK] = string_arg
        else
          options[:company] = string_arg.gsub(/[(,?!\''"":.)]/, '')
        end
      end
      options
    end

    private_class_method :handle_string_args

    def self.handle_hash_args(hash_arg)
      options = hash_arg
      if hash_arg[:symbol] || hash_arg[:cik]
        options[:CIK] = (hash_arg[:symbol] || hash_arg[:cik])
        return options
      end
      options[:company] = company_name_from_hash_args(hash_arg)
      options
    end

    private_class_method :handle_hash_args

    def self.company_name_from_hash_args(args)
      return "#{ args[:last] } #{ args[:first] }" if args[:first] && args[:last]
      return args[:name].gsub(/[(,?!\''"":.)]/, '') if args[:name]
    end

    private_class_method :company_name_from_hash_args

    def initialize
      self.host = 'www.sec.gov'
      self.scheme = 'http'
      self.path = 'cgi-bin'
    end

    def []=(key, value)
      query_values[key] = value
      self
    end

    def output_atom
      query_values.merge!(output: 'atom')
      self
    end

    def to_s
      uri.to_s
    end

    def to_str
      to_s
    end

    private

    def uri
      Addressable::URI.new(
        host: host,
        scheme: scheme,
        path: path,
        query_values: query_values
      )
    end
  end
end
