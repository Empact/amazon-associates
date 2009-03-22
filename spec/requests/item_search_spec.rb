require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Amazon
  module Associates
    describe ".item_search" do
      context "when omitting required parameters" do
        it "should fail" do
          proc { Amazon::Associates.item_search(nil) }.should raise_error(Amazon::Associates::RequiredParameterMissing)
        end
      end

      context "when the country is not recognized" do
        it "should fail" do
          proc { Amazon::Associates.item_search('ruby', :country => :asfdkjjk) }.should raise_error(Amazon::Associates::RequestError)
        end
      end

      context "on valid request" do
        before(:all) do
          @response = Amazon::Associates.item_search("ruby", :item_page => 2)
        end

        it_should_behave_like "Amazon Associates response"
      end
    end
  end
end