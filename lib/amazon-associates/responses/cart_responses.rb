module Amazon
  module Associates
    class CartResponse < Response
      xml_reader :cart, Cart, :from => 'Cart', :required => true
    end

    class CartCreateResponse < CartResponse
      xml_name 'CartCreateResponse'
    end

    class CartGetResponse < CartResponse
    end

    class CartAddResponse < CartResponse
    end

    class CartModifyResponse < CartResponse
    end

    class CartClearResponse < CartResponse
      xml_name 'CartClearResponse'
    end
  end
end