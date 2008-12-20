require File.join(File.dirname(__FILE__), '../test_helper')

module Amazon
  class A2s
    class CartTest < Test::Unit::TestCase
      def setup
        @potter = Amazon::A2s.item_search("potter").items[0]
        @batman = Amazon::A2s.item_search("batman").items[0]
        @create_response = Amazon::A2s.cart_create(:items => {@potter => 1})
      end

      def test_cart_create
        assert !@create_response.cart.blank?
      end

      def test_cart_get
        fetchedCart = Amazon::A2s.cart_get(@create_response.cart)
        assert_equal @create_response.cart.items, fetchedCart.cart.items
      end

      def test_cart_add
        result = Amazon::A2s.cart_add(@create_response.cart, :items => {@batman => 5})

        assert_equal 2, result.cart.items.size # Has both items
        assert_equal 6, result.cart.items.sum {|i| i.quantity } # 6 total
        assert       result.cart.items.include?(@batman) # includes the new
        assert_equal 5, result.cart.items.find {|i| i == @batman }.quantity # 5 of the new (hence 1 of the other
      end

      def test_cart_modify
        result = Amazon::A2s.cart_modify(@create_response.cart, :items => {@create_response.cart.items[0] => 5})

        assert_equal 1, result.cart.items.size
        assert_equal 5, result.cart.items.sum {|i| i.quantity }
        assert       result.cart.items.include?(@potter)
        assert_equal 5, result.cart.items.find {|i| i == @potter }.quantity
      end

      def test_cart_clear
        result = Amazon::A2s.cart_clear(@create_response.cart)

        assert_equal 0, result.cart.items.size
        assert_equal 0, result.cart.items.sum {|i| i.quantity }
        assert       !result.cart.items.include?(@potter)
      end
    end

    class CartTestBroughtIn < Test::Unit::TestCase
      def setup
        @items = %w(potter book jumper).collect do |word|
          Item.first(:keywords => word)
        end
      end

      def new_cart(items = [@items[0], @items[1]])
        cart = Cart.create(items)
        assert !cart.changed?
        cart
      end

      def test_create_with_hash
        items = {@items[0] => 3,
                 @items[1] => 2}
        cart = new_cart(items)
        assert_equal cart.items.size, items.size
        assert_equal 5, cart.quantity
        assert !cart.changed?
      end

      def test_create_with_array
        items = [@items[0], @items[1]]
        cart = new_cart(items)
        assert_equal cart.items.size, items.size
        assert_equal 2, cart.quantity
      end

      def test_get_returns_the_same_as_the_create_that_made_it
        cart = new_cart
        get_cart = Cart.get(:cart_id => cart.id, :hMAC => cart.hmac)
        assert_equal cart, get_cart
      end

      def test_get_handles_natural_key_alternatives
        cart = new_cart
        get_cart = Cart.get(:id => cart.id, :hmac => cart.hmac)
        assert_equal cart, get_cart
      end

      def test_add_has_no_effect_without_save
        cart = new_cart
        cart.add(@items[2])
        assert cart.changed?
        assert_equal 2, cart.quantity
        assert_equal 2, cart.items.size
      end

      def test_add_increases_quantity_after_save
        cart = new_cart
        cart.add(@items[2])
        cart.save

        assert_equal 3, cart.quantity
        assert_equal 3, cart.items.size
        assert !cart.changed?
      end

      def test_modify_has_no_effect_without_save
        cart = new_cart
        cart.add(@items[1])
        assert cart.changed?
        assert_equal 2, cart.quantity
        assert_equal 2, cart.items.size
      end

      def test_modify_increases_quantity_after_save
        cart = new_cart
        cart.add(@items[1])
        cart.save
        assert_equal 3, cart.quantity
        assert_equal 2, cart.items.size
        assert !cart.changed?
      end

      def test_items_is_a_const_view
        cart = new_cart
        assert_raise(TypeError) do
          cart.items.clear
        end
      end

      def test_clear_has_no_effect_without_save
        cart = new_cart
        cart.clear
        assert cart.changed?
        assert_equal 2, cart.quantity
        assert_equal 2, cart.items.size
      end

      def test_clear_removes_items_after_save
        cart = new_cart
        cart.clear
        cart.save

        assert !cart.changed?
        assert cart.items.empty?
        assert_equal 0, cart.quantity
      end
    end
  end
end