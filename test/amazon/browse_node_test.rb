require File.dirname(__FILE__) + "/../test_helper"

class Amazon::Associates::BrowseNodeLookupTest < Test::Unit::TestCase
  include FilesystemTestHelper

  def setup
    set_valid_caching_options
  end

  def test_browse_node_lookup_with_invalid_request
    assert_raise(Amazon::Associates::RequiredParameterMissing) do
      Amazon::Associates.browse_node_lookup(nil)
    end
  end

  def test_browse_node_lookup_with_no_result
    assert_raise(Amazon::Associates::InvalidParameterValue) do
      Amazon::Associates.browse_node_lookup("abc")
    end
  end

	def test_items_have_browsenodes
	  item = Amazon::Associates.item_lookup('B000ROI682', :response_group => 'BrowseNodes').items.first
	  assert item.browse_nodes.size > 1
    item.browse_nodes.each do |browsenode|
	    assert_kind_of Amazon::Associates::BrowseNode, browsenode
	    assert !browsenode.to_s.include?('&amp;'), browsenode.to_s
	  end
	end

  def test_browse_nodes_have_top_sellers
    assert !Amazon::Associates.browse_node_lookup(:response_group => 'TopSellers', :browse_node_id => 493964).browse_nodes.first.top_sellers.empty?
  end
end
