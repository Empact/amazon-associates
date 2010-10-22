%w{errors extensions/core types/api_result
   types/error types/customer_review types/editorial_review types/ordinal types/listmania_list types/browse_node types/measurement types/image types/image_set types/price types/offer types/item types/requests types/cart
   responses/response responses/item_search_response responses/item_lookup_response responses/similarity_lookup_response responses/browse_node_lookup_response responses/cart_responses }.each do |file|
  require File.join(File.dirname(__FILE__), file)
end

require 'net/http'
require 'cgi'
require 'hmac'
require 'hmac-sha2'
require 'base64'

module Amazon
  module Associates
    def self.request(actions, &block)
      actions.each_pair do |action, main_arg|
        meta_def(action) do |*args|
          opts = args.extract_options!
          opts[main_arg] = args.first unless args.empty?
          opts[:operation] = action.to_s.camelize

          opts = yield opts if block_given?
          send_request(opts)
        end
      end
    end

  private
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      opts.to_options!
      opts.reverse_merge! options.except(:caching_options, :caching_strategy)
      if opts[:aWS_access_key_id].blank?
        raise ArgumentError, "amazon-associates requires the :aws_access_key_id option"
      end

      request_url = prepare_url(opts)
      response = nil

      if cacheable?(opts['Operation'])
        FilesystemCache.sweep

        response = FilesystemCache.get(request_url)
      end

      if response.nil?
        log "Request URL: #{request_url}"

        response = Net::HTTP.get_response(URI::parse(request_url))
        unless response.kind_of? Net::HTTPSuccess
          raise RequestError, "HTTP Response: #{response.inspect}"
        end
        cache_response(request_url, response) if cacheable?(opts['Operation'])
      end

      doc = ROXML::XML::Parser.parse(response.body).root
      eval(doc.name).from_xml(doc, request_url)
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

    TLDS = HashWithIndifferentAccess.new(
        'us' => 'com',
        'uk' => 'co.uk',
        'ca' => 'ca',
        'de' => 'de',
        'jp' => 'co.jp',
        'fr' => 'fr'
    )
    def self.tld(country)
      TLDS.fetch(country || 'us') do
        raise RequestError, "Invalid country '#{country}'"
      end
    end

    def self.prepare_url(opts)
      opts = opts.to_hash.to_options!
      raise opts.inspect if opts.has_key?(:cart)
      opts.assert_valid_keys(*valid_arguments(opts[:operation]))

      params = Hash[opts.map do |(k, v)|
        v *= ',' if v.is_a? Array
        [k.to_s.camelize, v.to_s]
      end]

      params.merge!(
        'Service' => 'AWSECommerceService',
        'Timestamp' => Time.now.gmtime.iso8601,
        'SignatureVersion' => '2',
        'SignatureMethod' => "HmacSHA256"
      )

      unsigned_uri = URI.parse("http://webservices.amazon.#{tld(opts.delete("Country"))}/onca/xml?#{params.sort { |a, b| a[0] <=> b[0] }.map { |key, val| "#{key}=#{CGI::escape(val).gsub('+', '%20')}" }.join("&")}")
      hmac = HMAC::SHA256.new(ENV['AMAZON_SECRET_ACCESS_KEY'])
      hmac.update("GET\n#{unsigned_uri.host}\n#{unsigned_uri.path}\n#{unsigned_uri.query}")
      "#{unsigned_uri}&Signature=#{CGI::escape(Base64.encode64(hmac.digest).chomp)}"
    end

    def self.cacheable?(operation)
      caching_enabled? && !operation.starts_with?('Cart')
    end

    def self.caching_enabled?
      !options[:caching_strategy].blank?
    end

    def self.cache_response(request, response)
      FilesystemCache.cache(request, response)
    end
  end
end
