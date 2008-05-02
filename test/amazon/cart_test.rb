require File.join(File.dirname(__FILE__), '../test_helper')

class Amazon::A2s::CartTest < Test::Unit::TestCase
  def setup
    @potter = Amazon::A2s.item_search("potter").items[0]
    @create_response = Amazon::A2s.cart_create(:items => {@potter.to_hash => 1})
  end

  def test_cart_create
    assert !@create_response.cart.blank?
  end

  def test_cart_get
    fetchedCart = Amazon::A2s.cart_get(@create_response.text_at(:cartid),
                                       :hmac => @create_response.text_at(:urlencodedhmac))
    assert_equal @create_response.cart.items.to_s, fetchedCart.cart.items.to_s
  end
end
