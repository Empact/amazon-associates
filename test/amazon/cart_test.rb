require File.join(File.dirname(__FILE__), '../test_helper')

class Amazon::A2s::CartTest < Test::Unit::TestCase
  def test_cart_create
    item = Amazon::A2s.item_search("potter").items[0].to_hash
    assert !Amazon::A2s.cart_create(:items => {item => 1}).cart.blank?
  end

  def test_cart_get
    item = Amazon::A2s.item_search("potter").items[0].to_hash
    cart = Amazon::A2s.cart_create(:items => {item => 1})
    fetchedCart = Amazon::A2s.cart_get(cart.text_at(:cartid), :hmac => cart.text_at(:urlencodedhmac))
    assert_equal cart.cart.items.to_s, fetchedCart.cart.items.to_s
  end
end
