require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Amazon
  module Associates
    describe Cart do
      before(:all) do
        @potter = Amazon::Associates::item_lookup("0545010225").item
        @batman = Amazon::Associates::item_search("batman").items.first
        @joker = Amazon::Associates::item_search("joker").items.first

        @existing_items = [@potter, @batman]
        @existing_cart = Cart.create(@potter => 1, @batman => 3)
      end

      describe "a cart", :shared => true do
        it "should have a valid purchase_url" do
          @cart.purchase_url.should_not be_blank
        end

        it "should have a valid hmac" do
          @cart.hmac.should_not be_blank
        end

        it "should have a valid id" do
          @cart.id.should_not be_blank
        end

        describe "#items" do
          subject { @cart.items }

          it { should be_an_instance_of(Array) }
          it { should be_frozen }
        end
      end

      describe "a valid cart", :shared => true do
        it_should_behave_like "a cart"

        it "should be in a valid state" do
          @cart.changed?.should be_false
        end
      end

      describe "a modified cart", :shared => true do
        it_should_behave_like "a cart"

        it "should be in a valid state" do
          @cart.changed?.should be_true
        end
      end

      describe ".create" do
        context "items passed in hash form" do
          before(:all) do
            @cart = Cart.create(@potter => 1, @batman => 3)
          end

          it_should_behave_like "a valid cart"

          it "should create a cart with those items in the quantities provided" do
            @cart.items.index_by(&:quantity).should == {1 => @potter, 3 => @batman}
          end
        end

        context "items passed in array form" do
          context "with actual items" do
            before(:all) do
              @cart = Cart.create([@potter, @batman])
            end

            it_should_behave_like "a valid cart"

            it "should create a chart with those items, implicitly 1 each" do
              @cart.items.should =~ [@potter, @batman]
              @cart.items.map(&:quantity).should == [1, 1]
            end
          end

          context "with hashes containing item asins" do
            before(:all) do
              @items = { { :asin => "0974514055" } => 2, { :asin => "0672328844" } => 3 }
              @cart = Cart.create(@items)
            end

            it_should_behave_like "a valid cart"

            describe "#items" do
              it "should match the passed items asins" do
                @cart.items.map(&:asin).should =~ @items.keys.map {|item| item[:asin] }
              end

              it "should match the passed items quantities" do
                @cart.items.map(&:quantity).should == @items.values
              end
            end
          end

          context "with hashes containing offer_listing_ids" do
            before(:all) do
              @items = { { :offer_listing_id => "MCK%2FnCXIges8tpX%2B222nOYEqeZ4AzbrFyiHuP6pFf45N3vZHTm8hFTytRF%2FLRONNkVmt182%2BmeX72n%2BbtUcGEtpLN92Oy9Y7"} => 2 }
              @cart = Cart.create(@items)
            end

            it_should_behave_like "a valid cart"

            describe "#items" do
              it "should match the passed items asins" do
                @cart.items.size.should == @items.size
              end

              it "should not have the offer_listing_id reflected immediately in the cart item" do
                @cart.items.first.cart_item_id.should_not == @items.keys.first[:offer_listing_id]
              end

              it "should match the passed items quantities" do
                @cart.items.map(&:quantity).should == @items.values
              end
            end
          end
        end
      end

      describe ".get" do
        describe "gotten cart", :shared => true do
          subject { @cart }

          it { should == @existing_cart }

          it_should_behave_like "a valid cart"

          it "should have the same items as the original cart" do
            @cart.items.should == @existing_cart.items
          end
        end

        context "with an existing cart" do
          before(:all) do
            @cart = Cart.get(@existing_cart)
          end

          it_should_behave_like "gotten cart"
        end

        context "with an id and hmac" do
          before(:all) do
            @cart = Cart.get(:id => @existing_cart.id, :hmac => @existing_cart.hmac)
          end

          it_should_behave_like "gotten cart"
        end
      end

      it "should have the capacity to remove existing items (short of #clear)"
#      # Test cart_modify
#      def test_cart_modify
#        resp = Amazon::Associates.cart_get(:id => @cart_id, :hmac => @hmac)
#        cart_item_id = resp.cart.items.first.cart_item_id
#        resp = Amazon::Associates.cart_modify(:id => @cart_id, :hmac => @hmac,
#          :items => [{:cart_item_id => cart_item_id, :quantity => 2}])
#        item = resp.cart.items.first
#
#        assert resp.request.valid?
#        assert_equal 2, item.quantity
#        assert_not_nil resp.cart.purchase_url
#      end
#

      describe "#add" do
        context "adding a new item, on save" do
          before(:all) do
            @number_added = 3
            @item_added = @joker
            @existing_cart.should_not include(@item_added)
            @existing_cart.add(@item_added, @number_added)
            @cart = @existing_cart
          end

          context "before save" do
            it_should_behave_like "a modified cart"

            it "should be unchanged" do
              @existing_cart.should have(2).items
              @existing_cart.quantity.should == 4
            end
          end

          context "on save" do
            before(:all) do
              @existing_cart.should have(2).items
              lambda { @existing_cart.save }.should change(@existing_cart, :quantity).by(@number_added)
              @existing_cart.should have(3).items
            end

            it_should_behave_like "a valid cart"

            it "should include the old items" do
              @existing_cart.items.should include(*@existing_items)
            end

            it "should include the new item" do
              @existing_cart.items.should include(@item_added)
            end
          end
        end

        context "adding an existing item", :shared => true do
          context "before save" do
            it_should_behave_like "a modified cart"

            it "should be unchanged" do
              @existing_cart.should have(2).items
              @existing_cart.quantity.should == 4
            end
          end

          context "on save" do
            before(:all) do
              lambda { @existing_cart.save }.should change {
                @existing_cart.items.find {|item| item == @item_added }.quantity }.by(@number_added)

              @cart = @existing_cart
            end

            it_should_behave_like "a valid cart"

            it "should add the item in the quantity requested" do
              @existing_cart.should have(2).items
              @existing_cart.items.should =~ @existing_items
            end
          end
        end

        context "adding an existing item, on save, via add" do
          before(:all) do
            @number_added = 2
            @item_added = @existing_items.first
            @cart = @existing_cart
            @cart.add(@item_added, @number_added)
          end

          it_should_behave_like "adding an existing item"
        end

        context "adding an existing item, on save, via add" do
          before(:all) do
            @number_added = 1
            @item_added = @existing_items.first
            @cart = @existing_cart
            @cart << @item_added
          end

          it_should_behave_like "adding an existing item"
        end
      end

      describe "#clear" do
        before(:all) do
          @existing_quantity = @existing_cart.quantity
          @existing_quantity.should == 4
          @existing_cart.empty?.should be_false
          @existing_cart.clear
          @cart = @existing_cart
        end

        context "before #save" do
          it_should_behave_like "a modified cart"

          it "should have no effect" do
            @cart.empty?.should be_false
            @cart.items.should =~ @existing_items
          end
        end

        context "after #save" do
          before(:all) do
            @cart.should have(2).items

            lambda { @cart.save }.should change {
              @cart.quantity }.by(- @existing_quantity)
          end

          it_should_behave_like "a valid cart"

          it "should remove all items" do
            @cart.items.should == []
            @cart.items.should be_empty
            @cart.should be_empty
            @cart.quantity.should == 0
          end
        end
      end
    end
  end
end