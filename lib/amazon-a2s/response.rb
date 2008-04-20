require 'hpricot'

%w{ errors extensions/core extensions/hpricot }.each do |file|
  require File.join(File.dirname(__FILE__), file)
end

module Amazon
  class A2s
    # Response object returned after a REST call to Amazon service.
    class Response
      attr_accessor :doc

      # XML input is in string format
      def initialize(url, xml)
        @url = url.to_s
        @doc = Hpricot(xml)
        raise error if error
      end

      # Return true if request is valid.
      def valid_request?
        @doc.text_at("isvalid") == "True"
      end

      def request
        @doc.hash_at('request')
      end

      # Return error message.
      def error
        if code = @doc.text_at('error/code') and not IGNORE_ERRORS.include? code
          message = @doc.text_at('error/message')
          if exception = ERROR[code]
            exception.new("#{message} (#{@url})")
          else
            RuntimeError.new("#{code}: #{message} (#{@url})")
          end
        end
      end

      def cart
        @cart ||= @doc.at(:cart)
      end

      def items
        @items ||= @doc.search(:item)
      end

      def top_sellers
        @top_sellers ||= @doc.search('topsellers/topseller')
      end

      # Return current page no if :item_page option is when initiating the request.
      def item_page
        @item_page ||= @doc.int_at('itemsearchrequest/itempage"')
      end

      # Return total results.
      def total_results
        @total_results ||= @doc.int_at('totalresults')
      end

      # Return total pages.
      def total_pages
        @total_pages ||= @doc.int_at('totalpages')
      end
    end
  end
end
