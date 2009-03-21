require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Amazon
  module Associates
    describe Item do
      it "should equal anything with the same #asin" do
        item = Amazon::Associates::item_lookup("0545010225").item
        asin = item.asin
        item.should == Struct.new(:asin).new(asin)
      end
    end
  end
end