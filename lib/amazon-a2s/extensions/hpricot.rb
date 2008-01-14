require 'rubygems'
require 'active_support'

# TODO: Untange this inter-dependency...
%w{ browse_node image measurement ordinal price }.each do |type|
  require File.join(File.dirname(__FILE__), '..', 'types', type)    
end

module Hpricot
  class Element < OpenHash
    def initialize(value, attributes = {})
      merge! :value => value,
             :attributes => attributes
    end
  end
  
  # Extend with some convenience methods
  module Traverse
    def self.induce(type, &block)
      raise ArgumentError, "block missing" unless block_given?
      
      type_at, to_type, types_at = "#{type}_at", "to_#{type}", "#{type.to_s.pluralize}_at"
      if [type_at, to_type, types_at].any? {|m| method_defined?(m) }
        raise ArgumentError, "some methods already defined"
      end
      
      define_method type_at do |path|
        result = at(path) and yield result
      end
      define_method to_type do
        method(type_at).call('')
      end
      define_method types_at do |path|
        results = search(path) and results.collect {|r| yield r }
      end
    end

    # Get the text value of the given path, leave empty to retrieve current element value.
    induce :text do |result|
      result.inner_html
    end

    induce :int do |result|
      result = result.inner_html
      if result.to_i.zero? and !result.starts_with?('0')
        raise TypeError, "failed to convert String #{result.inspect} into Integer"
      end
      result.to_i
    end

    induce :bool do |result|
      case result.inner_html
      when '0': false
      when '1': true
      else
        raise TypeError, "String #{result.inspect} is not convertible to bool"
      end
    end

    # Get the unescaped HTML text of the given path.
    induce :unescaped do |result|
      CGI::unescapeHTML(result.inner_html)
    end

    induce :element do |result|
      # TODO: Use to_h here?
      attrs = result.attributes.inject({}) do |hash, attr|
        hash[attr[0].to_sym] = attr[1].to_s; hash
      end
    
      children = result.children
      if children.size == 1 and children.first.is_a? Text
        value = children.first.to_s
      else
        result = children.inject({}) do |hash, item|
          name = item.name.to_sym
          hash[name] ||= []
          hash[name] << item.to_hash
          hash
        end
        
        value = result.each_pair {|key, value| result[key] = value[0] if value.size == 1 }
      end
    
      (attrs.empty?) ? value : Element.new(value, attrs)
    end

    # TODO: This probably doesn't belong here...  References to Amazon:: types indicate as much anyway
    # Get the children element text values in hash format with the element names as the hash keys.
    induce :hash do |result|
      # TODO: date?, image? &c
      if ['width', 'height', 'length', 'weight'].include? result.name
        Amazon::Measurement.new(result.to_int, result.attributes['units'])
      elsif ['batteriesincluded', 'iseligibleforsupersavershipping', 'isautographed', 'ismemorabilia'].include? result.name
        result.to_bool
      elsif result.name == 'browsenode'
        Amazon::BrowseNode.new(result.text_at('browsenodeid'), result.text_at('name'), result.hash_at('ancestors/browsenode'))
      elsif result.name == 'edition'
        begin
          Amazon::Ordinal.new(result.to_int)
        rescue TypeError
          # a few edition types aren't ordinals (e.g., 1st, 2nd, 3rd), but strings (e.g., "First American Edition")
          result.to_text
        end 
      elsif result.name.starts_with? 'total' or result.name.starts_with? 'number'
        result.to_int
      elsif result.name.ends_with? 'price'
        Amazon::Price.new(result.text_at('formattedprice'), result.int_at('amount'), result.text_at('currencycode'))
      elsif result.name.ends_with? 'image'
        Amazon::Image.new(result.text_at('url'), result.int_at('width'), result.int_at('height')) 
      else
        result.to_element
      end      
    end
  end
end