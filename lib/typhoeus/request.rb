module Typhoeus
  class Request
    attr_accessor :method, :params, :body, :headers, :timeout, :user_agent, :response, :cache_timeout
    attr_reader   :url
    
    def initialize(url, options = {})
      @method           = options[:method] || :get
      @params           = options[:params]
      @body             = options[:body]
      @timeout          = options[:timeout]
      @headers          = options[:headers] || {}
      @user_agent       = options[:user_agent] || Typhoeus::USER_AGENT
      @cache_timeout    = options[:cache_timeout]
      @url              = @params ? "#{url}?#{params_string}" : url
      @on_complete      = nil
      @after_complete   = nil
      @handled_response = nil
    end
    
    def host
      slash_location = @url.index('/', 8)
      if slash_location
        @url.slice(0, slash_location)
      else
        query_string_location = @url.index('?')
        return query_string_location ? @url.slice(0, query_string_location) : @url
      end
    end
    
    def headers
      @headers["User-Agent"] = @user_agent
      @headers
    end
    
    def params_string
      params.keys.sort.collect do |k|
        value = params[k]
        if value.is_a? Hash
          value.keys.collect {|sk| CGI.escape("#{k}[#{sk}]") + "=" + CGI.escape(value[sk].to_s)}
        elsif value.is_a? Array
          key = CGI.escape(k.to_s)
          value.collect { |v| "#{key}=#{CGI.escape(v.to_s)}" }.join('&')
        else
          "#{CGI.escape(k.to_s)}=#{CGI.escape(params[k].to_s)}"
        end
      end.flatten.join("&")
    end
    
    def on_complete(&block)
      @on_complete = block
    end
    
    def after_complete(&block)
      @after_complete = block
    end
    
    def call_handlers
      if @on_complete
        @handled_response = @on_complete.call(response)
        call_after_complete
      end
    end
    
    def call_after_complete
       @after_complete.call(@handled_response) if @after_complete
    end
    
    def handled_response=(val)
      @handled_response = val
    end
    
    def handled_response
      @handled_response || response
    end
    
    def cache_key
      Digest::SHA1.hexdigest(url)
    end
  end
end