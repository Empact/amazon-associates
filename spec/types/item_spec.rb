require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Amazon
  module Associates
    describe Item do
      before(:all) do
        @item = Amazon::Associates::item_lookup("0545010225").item
      end

      it "should equal anything with the same #asin" do
        asin = @item.asin
        @item.should == Struct.new(:asin).new(asin)
      end

      describe "query for similar items", :shared => true do
        it "should return similar items" do
          @similar.should be_an_instance_of(Array)
          @similar.each {|item| item.should be_an_instance_of(Item) }
          @similar.should_not include(@item)
          @similar.should have_at_least(10).items
        end
      end

      describe ".similar" do
        before(:all) do
          @similar = Item.similar(@item.asin)
        end
        it_should_behave_like "query for similar items"
      end

      describe "#similar" do
        before(:all) do
          @similar = @item.similar
        end
        it_should_behave_like "query for similar items"
      end
    end
  end
end