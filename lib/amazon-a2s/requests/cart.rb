require File.join(File.dirname(__FILE__), '../request')

class Hash
  def map_keys!(keys)
    keys.each_pair do |new, old|
      store(new, delete(old)) if has_key?(old)
    end
  end
end

module Amazon
  class A2s
  private
    def self.unpack_item(opts, index, item, count = 1)
      item = item.to_hash.dup
      unless [:offer_listing_id, :asin, :list_item_id, :cart_item_id].any?{|id| item.has_key?(id)}
        raise ArgumentError, "item needs an OfferListingId, ASIN, or ListItemId"
      end

      if id = item.delete(:cartitemid)
        opts[:"Item.#{index}.CartItemId"] = id
      elsif id = item.delete(:offer_listing_id)
        opts[:"Item.#{index}.OfferListingId"] = id
      elsif id = item.delete(:asin)
        opts["Item.#{index}.ASIN"] = id
      elsif id = item.delete(:list_item_id)
        opts["Item.#{index}.ListItemId"] = id
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

  public
    # Cart operations build the Item tags from the ASIN

    # Creates remote shopping cart containing _asin_
    request :cart_create => :items do |opts|
      opts = unpack_items(opts)
    end

    # Adds item to remote shopping cart
    request :cart_add => :cart_id do |opts|
      opts = unpack_items(opts)
      opts[:cart_id] ||= opts.delete(:cartid)
      opts[:hMAC] ||= opts.delete(:urlencodedhmac)
      opts.map_keys!(:cart_id => :cartid,
                     :cart_id => :id,
                     :hMAC => :hmac)
#      raise opts.pp_to_s
    end

    # Adds item to remote shopping cart
    request :cart_get => :cart_id do |opts|
      if opts.has_key? :id and opts.has_key? :cart_id and opts[:id] != opts[:cart_id]
        raise ArgumentError, "the id and cart_id parameters are both specified, when the have the same meaning"
      end
      opts[:cart_id] ||= opts.delete(:cartid)
      opts[:hMAC] ||= opts.delete(:urlencodedhmac)
      opts.map_keys!(:cart_id => :cartid,
                     :cart_id => :id,
                     :hMAC => :hmac)
    end

    # modifies _cart_item_id_ in remote shopping cart
    # _quantity_ defaults to 0 to remove the given _cart_item_id_
    # specify _quantity_ to update cart contents
    request :cart_modify => :cart_id do |opts|
      opts = unpack_items(opts)
      opts[:cart_id] ||= opts.delete(:cartid)
      opts[:hMAC] ||= opts.delete(:urlencodedhmac)
      opts.map_keys!(:cart_id => :cartid,
                     :cart_id => :id,
                     :hMAC => :hmac)
    end

    # clears contents of remote shopping cart
    request :cart_clear => :cart_id do |opts|
      opts[:cart_id] ||= opts.delete(:cartid)
      opts[:hMAC] ||= opts.delete(:urlencodedhmac)
      opts.map_keys!(:cart_id => :cartid,
                     :cart_id => :id,
                     :hMAC => :hmac)
    end
  end
end
