require File.join(File.dirname(__FILE__), '../test_helper')

class Amazon::A2s::CartTest < Test::Unit::TestCase
  def test_cart_create
    item = Amazon::A2s.item_search("potter").items[0].to_hash[:asin]
    assert Amazon::A2s.cart_create(:items => {item => 1})
  end
end
