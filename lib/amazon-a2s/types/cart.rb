require 'roxml'

module Amazon
  class Cart
    include ROXML

    xml_reader :items, [CartItem], :from => 'CartItem', :in => 'CartItems'
    xml_reader :id, :from => 'CartId'
    xml_reader :hmac, :from => 'HMAC'

    def to_amazon_arg
      {:cart_id => id,
       :hMAC => hmac}
    end
  end
end