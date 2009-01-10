require 'will_paginate/collection'

module Amazon
  module Associates
    class Item < ApiResult
      xml_name 'Item'
      xml_reader :asin, :from => 'ASIN'
      xml_reader :detail_page_url
      xml_reader :list_price, Price, :from => 'ListPrice', :in => 'ItemAttributes'
      xml_reader :attributes, {:key => :name,
                               :value => :content}, :in => 'ItemAttributes'
      xml_reader :small_image, Image
      #TODO: would be nice to have :key => '@category' and :value => {[Image] => 'SwatchImage'}
      xml_reader :image_sets, [ImageSet]
      xml_reader :listmania_lists, [ListmaniaList]
      xml_reader :browse_nodes, [BrowseNode]
      xml_reader :offers, [Offer]
      # TODO: This should be offers.total_new
      xml_reader :total_new_offers, :from => 'TotalNew', :in => 'OfferSummary', :as => Integer
      # TODO: This should be offers.total
      xml_reader :total_offers, :in => 'Offers', :as => Integer

      xml_reader :creators, {:key => {:attr => 'Role'}, :value => :content}, :in => 'ItemAttributes'
      xml_reader :authors, [:text], :in => 'ItemAttributes'
      xml_reader :edition, Ordinal, :in => 'ItemAttributes'
      xml_reader :batteries_included?, :in => 'ItemAttributes'
      xml_reader :lowest_new_price, Price, :in => 'OfferSummary'

      xml_reader :editorial_reviews, [EditorialReview]
      xml_reader :customer_reviews, [CustomerReview]

      def ==(other)
        asin == other.asin
      end

      def eql?(other)
        asin == other.asin
      end

      def author
        authors.only
      end

      def inspect
        "#<#{self.class}: #{asin} #{attributes.inspect}>"
      end

      PER_PAGE = 10
      MAX_PAGE = 400
      MAX_COUNT = MAX_PAGE * PER_PAGE

      def self.find(scope, opts = {})
        opts = opts.dup # it seems this hash picks up some internal amazon stuff if we don't copy it

        if scope.is_a? String
          opts.merge!(:item_id => scope, :item_type => 'ASIN')
          scope = :one
        end

        case scope
        when :top_sellers then top_sellers(opts)
        when :similar then similar(opts)
        when :all     then all(opts)
        when :first   then first(opts)
        when :one     then one(opts)
        else
          raise ArgumentError, "scope should be :all, :first, :one, or an item id string"
        end
      end

      def self.top_sellers(opts)
        opts.merge!(:response_group => 'TopSellers')
        opts[:browse_node_id] = opts.delete(:browse_node).id if opts[:browse_node]
        items = Amazon::Associates.browse_node_lookup(opts).top_sellers.map {|i| i.text_at('asin') }
        Amazon::Associates.item_lookup(:item_id => items * ',', :response_group => SMALL_RESPONSE_GROUPS).items
      end

      def self.similar(opts)
        opts.reverse_merge!(:response_group => SMALL_RESPONSE_GROUPS)
        Amazon::Associates.similarity_lookup(opts.delete(:item_id), opts).items
      end

      def self.top_sellers(opts)
        opts.merge!(:response_group => 'TopSellers')
        opts[:browse_node_id] = opts.delete(:browse_node).id if opts[:browse_node]
        items = Amazon::Associates.browse_node_lookup(opts).browse_nodes.map(&:top_sellers).flatten.map(&:asin)
        Amazon::Associates.item_lookup(:item_id => items * ',', :response_group => SMALL_RESPONSE_GROUPS).items
      end

      def self.first(opts)
        all(opts).first
      end

      def self.all(opts)
        opts = opts.dup
        unless %w[All Blended Merchants].include? opts[:search_index]
          opts.reverse_merge!(:merchant_id => 'Amazon',
                              :condition => 'All')
        end
        opts[:availability] ||= 'Available' unless opts[:condition].nil? or opts[:condition] == 'New'
        opts[:item_page]    ||= (opts.delete(:page) || 1)
        prep_responses(opts)

        response = Amazon::Associates.item_search(opts)

        # TODO: Max count is different for different indexes, for example, All only returns 5 pages
        max_count = [response.total_results, MAX_COUNT].min
        WillPaginate::Collection.create(response.current_page, PER_PAGE, max_count) do |pager|
          # TODO: Some of the returned items may not include offers, we may need something like this:
          #.reject {|i| i.offers[:totaloffers] == '0' }
          pager.replace response.items
        end
      end

      def self.one(opts)
        prep_responses(opts)
        Amazon::Associates.item_lookup(opts.delete(:item_id), opts).items.first
      end

    private
      SMALL_RESPONSE_GROUPS = %w{Small ItemAttributes Images}
      DEFAULT_RESPONSE_GROUPS = SMALL_RESPONSE_GROUPS + %w{Offers VariationSummary BrowseNodes}

      def self.prep_responses(opts)
        opts[:response_group] ||= []
        unless opts[:response_group].is_a? Array
          raise ArgumentError, "Response groups are required to be in array form"
        end
        opts[:response_group] += DEFAULT_RESPONSE_GROUPS
      end
    end

    class CartItem < Item
      # TODO: This could probably just be #id
      xml_reader :cart_item_id, :from => 'CartItemId'
      xml_reader :quantity, :from => 'Quantity', :as => Integer
    end
  end
end