require 'roxml'

module Amazon
  class Cart
    include ROXML

    xml_reader :items, [Item], :from => 'CartItem'
    xml_reader :id, :from => 'CartId'
    xml_reader :hmac, :from => 'HMAC'

    def to_amazon_arg
      {:cartid => id,
       :hMAC => hmac}
    end
  end
end