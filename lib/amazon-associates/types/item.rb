require 'will_paginate/collection'

module Amazon
  module Associates
    class Item < ApiResult
      xml_name 'Item'

      xml_reader :asin, :from => 'ASIN'
      xml_reader :detail_page_url, :from => 'DetailPageURL'
      xml_reader :list_price, :as => Price, :in => 'xmlns:ItemAttributes'
      xml_reader :attributes, :as => {:key => :name,
                                      :value => :content}, :in => 'xmlns:ItemAttributes'
      xml_reader :small_image, :as => Image
      xml_reader :medium_image, :as => Image
      #TODO: would be nice to have :key => '@category' and :value => {[Image] => 'SwatchImage'}
      xml_reader :image_sets, :as => [ImageSet] do |sets|
        sets.index_by(&:category)
      end
      xml_reader :listmania_lists, :as => [ListmaniaList]
      xml_reader :browse_nodes, :as => [BrowseNode]
      xml_reader :offers, :as => [Offer]
      # TODO: This should be offers.total_new
      xml_reader :total_new_offers, :from => 'TotalNew', :in => 'xmlns:OfferSummary', :as => Integer
      # TODO: This should be offers.total
      xml_reader :total_offers, :in => 'xmlns:Offers', :as => Integer

      xml_reader :creators, :as => {:key => '@Role', :value => :content}, :in => 'xmlns:ItemAttributes'
      xml_reader :authors, :as => [], :in => 'xmlns:ItemAttributes'
      xml_reader :edition, :as => Ordinal, :in => 'xmlns:ItemAttributes'
      xml_reader :lowest_new_price, :as => Price, :in => 'xmlns:OfferSummary'
      xml_reader :publisher, :studio, :batteries_included?, :label, :brand, :in => 'xmlns:ItemAttributes'

      xml_reader :editorial_reviews, :as => [EditorialReview]
      xml_reader :customer_reviews, :as => [CustomerReview], :in => 'xmlns:CustomerReviews'
      xml_reader :features, :as => [], :in => 'xmlns:ItemAttributes'

      alias_method :id, :asin

      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations

      def persisted?
        true
      end

      def amazon_product_description
        editorial_reviews.detect {|r| r.source == 'Amazon.com Product Description' }.try(:content)
      end

      def ==(other)
        asin == other.asin
      end

      def eql?(other)
        asin == other.asin
      end

      def author
        authors.only
      end

      def title
        root_title || attr_title
      end

      def inspect
        "#<#{self.class}: #{asin} #{attributes.inspect}>"
      end

      PER_PAGE = 10

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
        opts = opts.dup.to_options!
        opts.merge!(:response_group => 'TopSellers')
        opts[:browse_node_id] = opts.delete(:browse_node).id if opts[:browse_node]
        items = Amazon::Associates.browse_node_lookup(opts).top_sellers.map {|i| i.text_at('asin') }
        Amazon::Associates.item_lookup(:item_id => items * ',', :response_group => SMALL_RESPONSE_GROUPS).items
      end

      def self.similar(*ids)
        opts = ids.extract_options!
        opts.reverse_merge!(:response_group => SMALL_RESPONSE_GROUPS)
        Amazon::Associates.similarity_lookup(ids, opts).items
      end

      def self.top_sellers(opts)
        opts = opts.dup.to_options!
        opts.merge!(:response_group => 'TopSellers')
        opts[:browse_node_id] = opts.delete(:browse_node).id if opts[:browse_node]
        items = Amazon::Associates.browse_node_lookup(opts).browse_nodes.map(&:top_sellers).flatten.map(&:asin)
        Amazon::Associates.item_lookup(:item_id => items * ',', :response_group => SMALL_RESPONSE_GROUPS).items
      end

      def self.first(opts)
        all(opts).first
      end

      def self.all(opts)
        opts = opts.dup.to_options!
        unless %w[All Blended Merchants].include? opts[:search_index]
          opts.reverse_merge!(:merchant_id => 'Amazon',
                              :condition => 'All')
        end
        opts[:availability] ||= 'Available' unless opts[:condition].nil? or opts[:condition] == 'New'
        opts[:item_page]    ||= (opts.delete(:page) || 1)
        prep_responses(opts)

        response = Amazon::Associates.item_search(opts)

        # TODO: Max count is different for different indexes, for example, All only returns 5 pages
        WillPaginate::Collection.create(response.current_page, PER_PAGE, response.total_results) do |pager|
          # TODO: Some of the returned items may not include offers, we may need something like this:
          #.reject {|i| i.offers[:totaloffers] == '0' }
          pager.replace response.items
        end
      end

      def self.one(opts)
        prep_responses(opts)
        Amazon::Associates.item_lookup(opts.delete(:item_id), opts).items.first
      end

      def similar
        Item.similar(asin)
      end

    private
      xml_reader :attr_title, :from => 'xmlns:Title', :in => 'xmlns:ItemAttributes'
      xml_reader :root_title, :from => 'xmlns:Title'

      SMALL_RESPONSE_GROUPS = %w{Small ItemAttributes Images}
      DEFAULT_RESPONSE_GROUPS = SMALL_RESPONSE_GROUPS + %w{Offers VariationSummary BrowseNodes}

      def self.prep_responses(opts)
        opts[:response_group]
        if opts[:response_group]
          Array.wrap(opts[:response_group])
        else
          DEFAULT_RESPONSE_GROUPS
        end
      end
    end

    class CartItem < Item
      # TODO: This could probably just be #id
      xml_reader :cart_item_id
      xml_reader :quantity, :as => Integer, :required => true
    end
  end
end