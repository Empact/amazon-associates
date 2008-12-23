require File.join(File.dirname(__FILE__), '../request')

module Amazon
  class A2s
  private
    def self.unpack_item(opts, index, item, count = 1)
      case item
      when CartItem
        opts[:"Item.#{index}.CartItemId"] = item.cart_item_id
      when Item
        opts["Item.#{index}.ASIN"] = item.asin
      else
        item = item.to_hash.dup
        unless [:offer_listing_id, :asin, :list_item_id, :cart_item_id].any?{|id| item.has_key?(id)}
          raise ArgumentError, "item needs an OfferListingId, ASIN, or ListItemId"
        end

        if id = item.offer_listing_id
          opts[:"Item.#{index}.OfferListingId"] = id
        elsif id = item.delete(:asin)
          opts["Item.#{index}.ASIN"] = id
        elsif id = item.delete(:list_item_id)
          opts["Item.#{index}.ListItemId"] = id
        end
      end
      opts[:"Item.#{index}.Quantity"] = count
    end

    def self.unpack_items(opts)
      raise ArgumentError, "items are required" if opts[:items].blank?

      opts.delete(:items).each_with_index do |(item, count), index|
        unpack_item(opts, index, item, count)
      end
      opts
    end

    def self.unpack_cart(opts)
      opts.merge!(opts.delete(:cart).to_hash) if opts[:cart]
      opts[:cart_id] ||= opts.delete(:id)
      opts[:hMAC] ||= opts.delete(:hmac)
      opts
    end

  public
    # Cart operations build the Item tags from the ASIN

    # Creates remote shopping cart containing _asin_
    request :cart_create => :items do |opts|
      unpack_items(opts)
    end

    # Adds item to remote shopping cart
    request :cart_add => :cart do |opts|
      opts = unpack_items(opts)
      unpack_cart(opts)
    end

    # Adds item to remote shopping cart
    request :cart_get => :cart do |opts|
      unpack_cart(opts)
    end

    # modifies _cart_item_id_ in remote shopping cart
    # _quantity_ defaults to 0 to remove the given _cart_item_id_
    # specify _quantity_ to update cart contents
    request :cart_modify => :cart do |opts|
      opts = unpack_items(opts)
      unpack_cart(opts)
    end

    # clears contents of remote shopping cart
    request :cart_clear => :cart do |opts|
      unpack_cart(opts)
    end
  end
end
