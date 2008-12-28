require File.join(File.dirname(__FILE__), '../test_helper')

module Amazon
  module Associates
    class CartTest < Test::Unit::TestCase
      def setup
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
      # create a cart to store cart_id and hmac for add, get, modify, and clear tests
      def setup
        @asin = "0672328844"
        resp = Amazon::Associates.cart_create(@asin)
        @cart_id = resp.doc.get_elements_by_tag_name("cartid").inner_text
        @hmac = resp.doc.get_elements_by_tag_name("hmac").inner_text
        item = resp.items.first
        # run tests for cart_create with default quantity while we"re at it
        assert resp.request_valid?
        assert_equal @asin, item.get("asin")
        assert_equal "1", item.get("quantity")
        assert_not_nil @cart_id
        assert_not_nil @hmac
      end

      # Test cart_get
      def test_cart_get
        resp = Amazon::Associates.cart_get(@cart_id, @hmac)
        assert resp.request_valid?
        assert_not_nil resp.doc.get_elements_by_tag_name("purchaseurl").inner_text
      end

      # Test cart_modify
      def test_cart_modify
        resp = Amazon::Associates.cart_get(@cart_id, @hmac)
        cart_item_id = resp.doc.get_elements_by_tag_name("cartitemid").inner_text
        resp = Amazon::Associates.cart_modify(cart_item_id, @cart_id, @hmac, 2)
        item = resp.items.first

        assert resp.request_valid?
        assert_equal "2", item.get("quantity")
        assert_not_nil resp.doc.get_elements_by_tag_name("purchaseurl").inner_text
      end

      # Test cart_clear
      def test_cart_clear
        resp = Amazon::Associates.cart_clear(@cart_id, @hmac)
        assert resp.request_valid?
      end

      ## Test cart_create with a specified quantity
      ## note this will create a separate cart
      def test_cart_create_with_quantity
        asin = "0672328844"
        resp = Amazon::Associates.cart_create(asin, :quantity => 2)
        assert resp.request_valid?
        item = resp.items.first
        assert_equal asin, item.get("asin")
        assert_equal "2", item.get("quantity")
        assert_not_nil resp.doc.get_elements_by_tag_name("cartid").inner_text
        assert_not_nil resp.doc.get_elements_by_tag_name("hmac").inner_text
      end

      # Test cart_create with an array of hashes representing multiple items
      def test_cart_create_with_multiple_items
        items = [ { :asin => "0974514055", :quantity => 2 }, { :asin => "0672328844", :quantity => 3 } ]
        resp = Amazon::Associates.cart_create(items)
        assert resp.request_valid?
        first_item, second_item = resp.items.reverse[0], resp.items.reverse[1]

        assert_equal items[0][:asin], first_item.get("asin")
        assert_equal items[0][:quantity].to_s, first_item.get("quantity")

        assert_equal items[1][:asin], second_item.get("asin")
        assert_equal items[1][:quantity].to_s, second_item.get("quantity")

        assert_not_nil resp.doc.get_elements_by_tag_name("cartid").inner_text
        assert_not_nil resp.doc.get_elements_by_tag_name("hmac").inner_text
      end

      # Test cart_create with offer_listing_id instead of asin
      def test_cart_create_with_offer_listing_id
        items = [ { :offer_listing_id => "MCK%2FnCXIges8tpX%2B222nOYEqeZ4AzbrFyiHuP6pFf45N3vZHTm8hFTytRF%2FLRONNkVmt182%2BmeX72n%2BbtUcGEtpLN92Oy9Y7", :quantity => 2 } ]
        resp = Amazon::Associates.cart_create(items)
        assert resp.request_valid?
        first_item = resp.items.first

        assert_equal items[0][:offer_listing_id], first_item.get("offerlistingid")
        assert_equal items[0][:quantity].to_s, first_item.get("quantity")

        assert_not_nil resp.doc.get_elements_by_tag_name("cartid").inner_text
        assert_not_nil resp.doc.get_elements_by_tag_name("hmac").inner_text
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