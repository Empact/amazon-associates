require 'roxml'

module Amazon
  class A2s
    class CartCreateResponse
      include ROXML

      xml_name :cartcreateresponse
      xml_reader :cart, Cart, :from => 'Cart', :required => true
    end
  end
end