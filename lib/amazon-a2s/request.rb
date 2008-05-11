require File.join(File.dirname(__FILE__), 'response')
require 'net/http'

module Amazon
  class A2s
    MAX_ITEMS = 99

    SERVICE_URLS = {
        :us => 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService',
        :uk => 'http://webservices.amazon.co.uk/onca/xml?Service=AWSECommerceService',
        :ca => 'http://webservices.amazon.ca/onca/xml?Service=AWSECommerceService',
        :de => 'http://webservices.amazon.de/onca/xml?Service=AWSECommerceService',
        :jp => 'http://webservices.amazon.co.jp/onca/xml?Service=AWSECommerceService',
        :fr => 'http://webservices.amazon.fr/onca/xml?Service=AWSECommerceService'
    }

    def self.request(actions, &block)
      actions.each_pair do |action, main_arg|
        meta_def(action) do |*args|
          opts = args.extract_options!
          opts[main_arg] = args.first unless args.empty?
          opts[:operation] = action.to_s.camelize

          yield opts if block_given?
          send_request(opts)
        end
      end
    end

    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      opts.reverse_merge! options
      request_url = prepare_url(opts)
      log "Request URL: #{request_url}"

      res = Net::HTTP.get_response(URI::parse(request_url))
      unless res.kind_of? Net::HTTPSuccess
        raise Amazon::RequestError, "HTTP Response: #{res.code} #{res.message}"
      end
      Response.new(request_url, res.body)
    end

  private
    def self.valid_arguments(operation)
      base_args = [:aWS_access_key_id, :operation, :associate_tag, :response_group]
      cart_args = [:cart_id, :url_encoded_hmac, :hMAC]
      item_args = (0..MAX_ITEMS).inject([:items]) do |all, i|
        all << :"Item.#{i}.ASIN"
        all << :"Item.#{i}.OfferListingId"
        all << :"Item.#{i}.CartItemId"
        all << :"Item.#{i}.Quantity"
        all
      end

      if operation == 'CartCreate'
        base_args + item_args
      elsif %w{CartAdd CartModify}.include? operation
        base_args + item_args + cart_args
      elsif operation == 'CartGet'
        base_args + cart_args
      else
        base_args + [
         :item_page, :item_id, :country, :type, :item_type,
         :browse_node_id, :actor, :artist, :audience_rating, :author,
         :availability, :brand, :browse_node, :city, :composer,
         :condition, :conductor, :director, :page, :keywords,
         :manufacturer, :maximum_price, :merchant_id,
         :minimum_price, :neighborhood, :orchestra,
         :postal_code, :power, :publisher, :search_index, :sort,
         :tag_page, :tags_per_page, :tag_sort, :text_stream,
         :title, :variation_page]
      end
    end

    def self.prepare_url(opts)
      opts.to_options.assert_valid_keys(*valid_arguments(opts[:operation]))

      country = opts.delete(:country) || 'us'
      request_url = SERVICE_URLS.fetch(country.to_sym) do
        raise Amazon::RequestError, "Invalid country '#{country}'"
      end

      qs = ''
      opts.each_pair do |k,v|
        next unless v
        v *= ',' if v.is_a? Array
        v = URI.encode(v.to_s) unless k == :hMAC
        qs << "&#{k.to_s.camelize}=#{ v.to_s }"
      end
      "#{request_url}#{qs}"
    end
  end
end
