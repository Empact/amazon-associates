require 'spec_helper'

describe Amazon::Associates do
  describe ".browse_node_lookup" do
    context "with 'TopSellers' response group" do
      before(:all) do
        @response = Amazon::Associates.browse_node_lookup("5", :response_group => "TopSellers")
      end
      it_should_behave_like "Amazon Associates response"

      it "should work" do
        @response.browse_nodes.first.id.should == '5'
        @response.request_query.response_groups.first.should == "TopSellers"
      end
    end

    context "with 'BrowseNodeInfo' response group" do
      before(:all) do
        @response = Amazon::Associates.browse_node_lookup("5", :response_group => "BrowseNodeInfo")
      end
      it_should_behave_like "Amazon Associates response"

      it "should work" do
        @response.request_query.response_groups.first.should == "BrowseNodeInfo"
      end
    end

    context "with 'NewReleases' response group" do
      before(:all) do
        @response = Amazon::Associates.browse_node_lookup("5", :response_group => "NewReleases")
      end
      it_should_behave_like "Amazon Associates response"

      it "should work" do
        @response.request_query.response_groups.first.should == "NewReleases"
      end
    end
  end
end