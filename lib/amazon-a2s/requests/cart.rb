require File.join(File.dirname(__FILE__), '../request')

module Amazon
  class A2s
  private
    def self.unpack_items(opts)
      raise ArgumentError, "items are required" if opts[:items].blank?

      opts.delete(:items).each_with_index do |(item, count), index|
        # item is an asin or offer_listing_id (latter preferred by amazon)
        opts[:"Item.#{index}.Quantity"] = count
        opts[:"Item.#{index}.ASIN"] = item
      end
      opts
    end

  public
    # Cart operations build the Item tags from the ASIN

    # Creates remote shopping cart containing _asin_
    request :cart_create => :items do |opts|
      opts = unpack_items(opts)
    end

    # Adds item to remote shopping cart
    request :cart_add => :cart_id do |opts|
      opts["Item.#{asin}.Quantity"] = opts[:quantity] || 1
      opts["Item.#{asin}.ASIN"] = opts[:asin]
      opts[:hMAC] = opts.delete(:hmac)
    end

    # Adds item to remote shopping cart
    request :cart_get => :cart_id do
      opts[:hMAC] = opts.delete(:hmac)
    end

    # modifies _cart_item_id_ in remote shopping cart
    # _quantity_ defaults to 0 to remove the given _cart_item_id_
    # specify _quantity_ to update cart contents
    request :cart_modify => :cart_id do |opts|
      asin = opts.delete(:asin)
      opts["Item.#{asin}.Quantity"] = opts.delete(:quantity)
      opts["Item.#{asin}.ASIN"] = asin

      opts[:hMAC] = opts.delete(:hmac)
    end

    # clears contents of remote shopping cart
    request :cart_clear => :cart_id do
      opts[:hMAC] = opts.delete(:hmac)
    end
  end
end
