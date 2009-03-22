require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Amazon
  module Associates
    describe "Amazon Associates response", :shared => true do
      describe "request" do
        subject { @response.request }
        it { should be_valid }
      end
    end

    describe ".item_search" do
      context "when omitting required parameters" do
        it "should fail" do
          proc { Amazon::Associates.item_search(nil) }.should raise_error(Amazon::Associates::RequiredParameterMissing)
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