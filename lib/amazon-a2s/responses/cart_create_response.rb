module Amazon
  class A2s
    class CartCreateResponse < Response
      xml_name 'CartCreateResponse'
      xml_reader :cart, Cart, :from => 'Cart', :required => true
    end
  end
end