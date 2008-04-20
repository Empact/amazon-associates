require File.join(File.dirname(__FILE__), 'request')

module Amazon
  class A2s
    # Cart operations build the Item tags from the ASIN
    # Item.ASIN.Quantity defaults to 1, unless otherwise specified in _opts_
    
    # Creates remote shopping cart containing _asin_
    request :cart_create => :asin do |opts|
      opts["Item.#{asin}.Quantity"] = opts[:quantity] || 1
      opts["Item.#{asin}.ASIN"] = opts.delete(:asin)
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
      opts["Item.#{asin}.CartItemId"] = opts.delete(:cart_item_id)
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
