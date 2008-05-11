require File.join(File.dirname(__FILE__), '../test_helper')

class Amazon::A2s::CartTest < Test::Unit::TestCase
  def setup
    @potter = Amazon::A2s.item_search("potter").items[0]
    @stopper = Amazon::A2s.item_search("stopper").items[0]
    @create_response = Amazon::A2s.cart_create(:items => {@potter.to_hash => 1})
  end

  def test_cart_create
    assert !@create_response.cart.blank?
  end

  def test_cart_get
    fetchedCart = Amazon::A2s.cart_get(@create_response.cart.to_hash.slice(:cartid, :urlencodedhmac))
    assert_equal @create_response.cart.items, fetchedCart.cart.items
  end

  def test_cart_add
    result = Amazon::A2s.cart_add(@create_response.cart.to_hash.slice(:cartid, :urlencodedhmac).merge(
                                  :items => {@stopper.to_hash => 5}))

    assert_equal 2, result.cart.items.size # Has both items
    assert_equal 6, result.cart.items.sum {|i| i.int_at(:quantity) } # 6 total
    assert       result.cart.items.include?(@stopper) # includes the new
    assert_equal 5, result.cart.items.find {|i| i == @stopper }.int_at(:quantity) # 5 of the new (hence 1 of the other
  end

  def test_cart_modify
    result = Amazon::A2s.cart_modify(@create_response.cart.to_hash.slice(:cartid, :urlencodedhmac).merge(
                                     :items => {@create_response.cart.items[0] => 5}))

    assert_equal 1, result.cart.items.size
    assert_equal 5, result.cart.items.sum {|i| i.int_at(:quantity) }
    assert       result.cart.items.include?(@potter)
    assert_equal 5, result.cart.items.find {|i| i == @potter }.int_at(:quantity)
  end

  def test_cart_clear
    result = Amazon::A2s.cart_clear(@create_response.cart.to_hash.slice(:cartid, :urlencodedhmac))

    assert_equal 0, result.cart.items.size
    assert_equal 0, result.cart.items.sum {|i| i.int_at(:quantity) }
    assert       !result.cart.items.include?(@potter)
  end
end
