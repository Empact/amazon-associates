require 'net/http'
require 'hpricot'
require 'cgi'

module Amazon
  class RequestError < StandardError; end
  
  class Ecs
    SERVICE_URLS = {
        :us => 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService',
        :uk => 'http://webservices.amazon.co.uk/onca/xml?Service=AWSECommerceService',
        :ca => 'http://webservices.amazon.ca/onca/xml?Service=AWSECommerceService',
        :de => 'http://webservices.amazon.de/onca/xml?Service=AWSECommerceService',
        :jp => 'http://webservices.amazon.co.jp/onca/xml?Service=AWSECommerceService',
        :fr => 'http://webservices.amazon.fr/onca/xml?Service=AWSECommerceService'
    }
    
    # Default search options 
    @options = {}
    @debug = false
    
    # see http://railstips.org/2006/11/18/class-and-instance-variables-in-ruby
    class << self; attr_accessor :debug, :options; end

    def self.configure(&block)
      raise ArgumentError, "Block is required." unless block_given?
      yield @options
    end
    
    # Search amazon items with search terms. Default search index option is 'Books'.
    # For other search type other than keywords, please specify :type => [search type param name].
    def self.item_search(terms, opts = {})
      opts[:operation] = 'ItemSearch'
      opts[:search_index] ||= 'Books'
      
      if type = opts.delete(:type) 
        opts[type.to_sym] = terms
      else 
        opts[:keywords] = terms
      end
      
      send_request(opts)
    end

    # Search an item by ASIN no.
    def self.item_lookup(item_id, opts = {})
      opts[:operation] = 'ItemLookup'
      opts[:item_id] = item_id
      
      send_request(opts)
    end    
          
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      opts = self.options.merge(opts)
      request_url = prepare_url(opts)
      log "Request URL: #{request_url}"
      
      res = Net::HTTP.get_response(URI::parse(request_url))
      unless res.kind_of? Net::HTTPSuccess
        raise Amazon::RequestError, "HTTP Response: #{res.code} #{res.message}"
      end
      Response.new(res.body)
    end

    # Response object returned after a REST call to Amazon service.
    class Response
      attr_accessor :doc
      
      # XML input is in string format
      def initialize(xml)
        @doc = Hpricot(xml)
      end

      # Return true if request is valid.
      def is_valid_request?
        (@doc/"isvalid").inner_html == "True"
      end

      # Return true if response has an error.
      def has_error?
        !error.empty?
      end

      # Return error message.
      def error
        @doc.get('error/message')
      end
      
      def items
        @items ||= (@doc/:item)
      end
      
      # Return current page no if :item_page option is when initiating the request.
      def item_page
        @item_page ||= (@doc/"itemsearchrequest/itempage").inner_html.to_i
      end

      # Return total results.
      def total_results
        @total_results ||= (@doc/:totalresults).inner_html.to_i
      end
      
      # Return total pages.
      def total_pages
        @total_pages ||= (@doc/:totalpages).inner_html.to_i
      end
    end
    
    protected
      def self.log(s)
        return unless debug
        if defined? RAILS_DEFAULT_LOGGER
          RAILS_DEFAULT_LOGGER.error(s)
        elsif defined? LOGGER
          LOGGER.error(s)
        else
          puts s
        end
      end
      
  private 
    def self.prepare_url(opts)
      country = opts.delete(:country) || 'us'
      request_url = SERVICE_URLS.fetch(country.to_sym) do
        raise Amazon::RequestError, "Invalid country '#{country}'"
      end
      
      qs = ''
      opts.each_pair do |k,v|
        next unless v
        v = v.join(',') if v.is_a? Array
        qs << "&#{k.to_s.camelize}=#{URI.encode(v.to_s)}"
      end      
      "#{request_url}#{qs}"
    end
  end
end

class String
  def camelize
    gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end
end

module Hpricot
  # Extend with some convenience methods
  module Traverse
    # Get the text value of the given path, leave empty to retrieve current element value.
    def get(path='')
      result = (self/path).collect {|i| i.inner_html }
      (result.size == 1) ? result.first : result
    end
    
    # Get the unescaped HTML text of the given path.
    def get_unescaped(path='')
      result = get(path)
      CGI::unescapeHTML(result) if result
    end
    
    # Get the children element text values in hash format with the element names as the hash keys.
    def get_hash(path='')
      result = at(path)
      result.children.inject({}) do |hash, item|
        hash[item.name.to_sym] = item.inner_html
        hash
      end if result
    end    
  end  
end