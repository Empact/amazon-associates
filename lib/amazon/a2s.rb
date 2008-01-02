require 'rubygems'
require 'active_support'
require 'net/http'
require 'hpricot'
require 'cgi'

class OpenHash < Hash
  def method_missing_with_attributes_query(meth, *args)
    fetch(meth) do
      method_missing_without_attributes_query(meth)
    end
  end
  alias_method_chain :method_missing, :attributes_query  
end

class Float
  def whole?
    (self % 1) < 0.0001
  end
end

class String
  def to_bool
    return false if self == '0'
    return true  if self == '1'
    raise ArgumentError, "String '#{self}' is not convertible to bool"
  end
end

module Amazon
  class RequestError < StandardError; end
  
  class InvalidParameterValue < ArgumentError; end
  class ParameterOutOfRange < InvalidParameterValue; end
  class RequiredParameterMissing < ArgumentError; end
  class ItemNotFound < StandardError; end
  
  # Map AWS error types to ruby exceptions
  ERROR = {
    'AWS.InvalidParameterValue' => InvalidParameterValue,
    'AWS.MissingParameters' => RequiredParameterMissing,
    'AWS.MinimumParameterRequirement' => RequiredParameterMissing,
    'AWS.ECommerceService.NoExactMatches' => ItemNotFound,
    'AWS.ParameterOutOfRange' => ParameterOutOfRange
  }  
  
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
        raise error if error
      end

      # Return true if request is valid.
      def is_valid_request?
        (@doc/"isvalid").inner_html == "True"
      end

      # Return error message.
      def error
        unless (message = @doc.get('error/message')).empty?
          code = @doc.get('error/code')
          if exception = ERROR[code]
            exception.new(message)
          else
            RuntimeError.new("#{code}: #{message}")
          end
        end
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

  class Element < OpenHash
    def initialize(value, attributes = {})
      merge! :value => value,
             :attributes => attributes
    end
  end
  
  class Measurement
    attr_reader :value, :units
    
    def initialize(value, units = nil)
      if value.is_a? Hpricot::Elem::Trav
        units = value.attributes['units']
        value = value.inner_html
      end
      
      @value = value.to_f
      @units = units.to_s
      
      if @units.starts_with? 'hundredths-'
        @value /= 100.0
        @units = @units.split('hundredths-')[1]
      end      
    end
    
    def to_s
      value = @value.whole? ? @value.to_i : @value
      #singularize here to avoid comparison problems
      units = @value == 1 ? @units.singularize : @units
      [value, units].join(' ')
    end
    alias_attribute :inspect, :to_s
    
    def to_i
      @value.round
    end
    
    def ==(other)
      @value == other.value and @units == other.units
    end
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
      if result = at(path)
        # TODO: price, date, int, &c
        if ['width', 'height', 'length', 'weight'].include? result.name
          Amazon::Measurement.new(result)
        elsif ['batteriesincluded', 'iseligibleforsupersavershipping', 'isautographed', 'ismemorabilia'].include? result.name
          result.inner_text.to_bool
        else
          # TODO: Use to_h here?
          attrs = result.attributes.inject({}) do |hash, attr|
            hash[attr[0].to_sym] = attr[1].to_s; hash
          end
        
          value = parse_children(result)
        
          (attrs.empty?) ? value : Amazon::Element.new(value, attrs)
        end
      end
    end
  private
    # TODO: Should go in element?
    def parse_children(result)
      children = result.children
      if children.size == 1 and children.first.is_a? Text
        children.first.to_s
      else
        result = children.inject({}) do |hash, item|
          name = item.name.to_sym
          hash[name] ||= []
          hash[name] << item.get_hash
          hash
        end
        
        result.each_pair {|key, value| result[key] = value[0] if value.size == 1 }
      end      
    end
  end
end

