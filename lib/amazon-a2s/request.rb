require File.join(File.dirname(__FILE__), 'response')
require File.join(File.dirname(__FILE__), 'responses/item_search_response')
require File.join(File.dirname(__FILE__), 'responses/item_lookup_response')
require File.join(File.dirname(__FILE__), 'responses/cart_create_response')
require 'net/http'

module Amazon
  class A2s
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

  private
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      opts.to_options!
      opts.reverse_merge! options
      request_url = prepare_url(opts)
      log "Request URL: #{request_url}"

      res = Net::HTTP.get_response(URI::parse(request_url))
      unless res.kind_of? Net::HTTPSuccess
        raise Amazon::RequestError, "HTTP Response: #{res.code} #{res.message}"
      end
      eval(ROXML::XML::Parser.parse(res.body).root.name).from_xml(res.body, request_url)
    end

    BASE_ARGS = [:aWS_access_key_id, :operation, :associate_tag, :response_group]
    CART_ARGS = [:cart_id, :hMAC]
    ITEM_ARGS = (0..99).inject([:items]) do |all, i|
      all << :"Item.#{i}.ASIN"
      all << :"Item.#{i}.OfferListingId"
      all << :"Item.#{i}.CartItemId"
      all << :"Item.#{i}.Quantity"
      all
    end
    OTHER_ARGS = [
      :item_page, :item_id, :country, :type, :item_type,
      :browse_node_id, :actor, :artist, :audience_rating, :author,
      :availability, :brand, :browse_node, :city, :composer,
      :condition, :conductor, :director, :page, :keywords,
      :manufacturer, :maximum_price, :merchant_id,
      :minimum_price, :neighborhood, :orchestra,
      :postal_code, :power, :publisher, :search_index, :sort,
      :tag_page, :tags_per_page, :tag_sort, :text_stream,
      :title, :variation_page
    ]
    VALID_ARGS = {
      'CartCreate' => ITEM_ARGS,
      'CartAdd' => ITEM_ARGS + CART_ARGS,
      'CartModify' => ITEM_ARGS + CART_ARGS,
      'CartGet' => CART_ARGS,
      'CartClear' => CART_ARGS
    }

    def self.valid_arguments(operation)
      BASE_ARGS + VALID_ARGS.fetch(operation, OTHER_ARGS)
    end

    TLDS = {
        'us' => 'com',
        'uk' => 'co.uk',
        'ca' => 'ca',
        'de' => 'de',
        'jp' => 'co.jp',
        'fr' => 'fr'
    }
    def self.request_url(country)
      tld = TLDS.fetch(country || 'us') do
        raise RequestError, "Invalid country '#{country}'"
      end

      "http://webservices.amazon.#{tld}/onca/xml?"
    end

    def self.prepare_url(opts)
      opts.to_options.assert_valid_keys(*valid_arguments(opts[:operation]))
      opts.merge!(:service => 'AWSECommerceService')

      request_url(opts.delete(:country)) + opts.each_pair! do |k, v|
        v *= ',' if v.is_a? Array
        [k.to_s.camelize, v]
      end.to_query
    end
  end
end
