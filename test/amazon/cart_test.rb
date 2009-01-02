require File.join(File.dirname(__FILE__), '../test_helper')

module Amazon
  module Associates
    class CartTest < Test::Unit::TestCase
      include FilesystemTestHelper

      def setup
        set_valid_caching_options

        @potter = Amazon::Associates.item_lookup("0545010225").items[0]
        @batman = Amazon::Associates.item_search("batman").items[0]
        @create_response = Amazon::Associates.cart_create(:items => {@potter => 1})
      end

      def test_cart_create
        assert !@create_response.cart.blank?
      end

      def test_cart_get
        fetched_cart = Amazon::Associates.cart_get(@create_response.cart)
        assert_equal @create_response.cart.items, fetched_cart.cart.items
      end

      def test_cart_add
        result = Amazon::Associates.cart_add(@create_response.cart, :items => {@batman => 5})

        assert_equal 2, result.cart.items.size # Has both items
        assert_equal 6, result.cart.items.sum {|i| i.quantity } # 6 total
        assert       result.cart.items.include?(@batman) # includes the new
        assert_equal 5, result.cart.items.find {|i| i == @batman }.quantity # 5 of the new (hence 1 of the other
      end

      def test_cart_modify
        result = Amazon::Associates.cart_modify(@create_response.cart, :items => {@create_response.cart.items[0] => 5})

        assert_equal 1, result.cart.items.size
        assert_equal 5, result.cart.items.sum {|i| i.quantity }
        assert       result.cart.items.include?(@potter)
        assert_equal 5, result.cart.items.find {|i| i == @potter }.quantity
      end

      def test_cart_clear
        result = Amazon::Associates.cart_clear(@create_response.cart)

        assert_equal 0, result.cart.items.size
        assert_equal 0, result.cart.items.sum {|i| i.quantity }
        assert       !result.cart.items.include?(@potter)
      end
    end

    class CartTestsFromAmazonAssociatesGem < Test::Unit::TestCase
      include FilesystemTestHelper

      # create a cart to store cart_id and hmac for add, get, modify, and clear tests
      def setup
        set_valid_caching_options

        @asin = "0672328844"
        resp = Amazon::Associates.cart_create(:items => {@asin => 1})
        @cart_id = resp.cart.id
        @hmac = resp.cart.hmac
        item = resp.cart.items.first
        # run tests for cart_create with default quantity while we"re at it
        assert resp.request.valid?
        assert_equal @asin, item.asin
        assert_equal 1, item.quantity
        assert_not_nil @cart_id
        assert_not_nil @hmac
      end

      # Test cart_get
      def test_cart_get
        resp = Amazon::Associates.cart_get(:id => @cart_id, :hmac => @hmac)
        assert resp.request.valid?
        assert_not_nil resp.cart.purchase_url
      end

      # Test cart_modify
      def test_cart_modify
        resp = Amazon::Associates.cart_get(:id => @cart_id, :hmac => @hmac)
        cart_item_id = resp.cart.items.first.cart_item_id
        resp = Amazon::Associates.cart_modify(:id => @cart_id, :hmac => @hmac,
          :items => [{:cart_item_id => cart_item_id, :quantity => 2}])
        item = resp.cart.items.first

        assert resp.request.valid?
        assert_equal 2, item.quantity
        assert_not_nil resp.cart.purchase_url
      end

      # Test cart_clear
      def test_cart_clear
        resp = Amazon::Associates.cart_clear(:id => @cart_id, :hmac => @hmac)
        assert resp.request.valid?
      end

      ## Test cart_create with a specified quantity
      ## note this will create a separate cart
      def test_cart_create_with_quantity
        asin = "0672328844"
        resp = Amazon::Associates.cart_create(:items => {asin => 2})
        assert resp.request.valid?
        item = resp.cart.items.first
        assert_equal asin, item.asin
        assert_equal 2, item.quantity
        assert_not_nil resp.cart.id
        assert_not_nil resp.cart.hmac
      end

      # Test cart_create with an array of hashes representing multiple items
      def test_cart_create_with_multiple_items
        items = [ { :asin => "0974514055", :quantity => 2 }, { :asin => "0672328844", :quantity => 3 } ]
        resp = Amazon::Associates.cart_create(:items => items)
        assert resp.request.valid?
        first_item, second_item = resp.cart.items[0], resp.cart.items[1]

        assert_equal items[0][:asin], first_item.asin
        assert_equal items[0][:quantity].to_i, first_item.quantity

        assert_equal items[1][:asin], second_item.asin
        assert_equal items[1][:quantity].to_i, second_item.quantity

        assert_not_nil resp.cart.id
        assert_not_nil resp.cart.hmac
      end

      # Test cart_create with offer_listing_id instead of asin
      def test_cart_create_with_offer_listing_id
        items = [ { :offer_listing_id => "MCK%2FnCXIges8tpX%2B222nOYEqeZ4AzbrFyiHuP6pFf45N3vZHTm8hFTytRF%2FLRONNkVmt182%2BmeX72n%2BbtUcGEtpLN92Oy9Y7", :quantity => 2 } ]
        resp = Amazon::Associates.cart_create(:items => items)
        assert resp.request.valid?
        first_item = resp.cart.items.first

        assert_not_equal items[0][:offer_listing_id], first_item.cart_item_id
        assert_equal items[0][:quantity].to_i, first_item.quantity

        assert_not_nil resp.cart.id
        assert_not_nil resp.cart.hmac
      end
    end

    class CartTestBroughtIn < Test::Unit::TestCase
      include FilesystemTestHelper

      def setup
        set_valid_caching_options

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

      def test_shift_is_equivalent_to_add
        cart = new_cart
        cart << @items[2]
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