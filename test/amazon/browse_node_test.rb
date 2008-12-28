require File.dirname(__FILE__) + "/../test_helper"

class Amazon::Associates::BrowseNodeLookupTest < Test::Unit::TestCase

  ## Test browse_node_lookup
  def test_browse_node_lookup
    resp = Amazon::Associates.browse_node_lookup("5", :response_group => "TopSellers")
    assert resp.request_valid?
    browse_node_tags = resp.doc.get_elements_by_tag_name("browsenodeid")
    browse_node_tags.each { |node| assert_equal("5", node.inner_text) }
    assert_equal "TopSellers", resp.doc.get_elements_by_tag_name("responsegroup").inner_text
  end

  def test_browse_node_lookup_with_browse_node_info_response
    resp = Amazon::Associates.browse_node_lookup("5", :response_group => "BrowseNodeInfo")
    assert resp.request_valid?
    assert_equal "BrowseNodeInfo", resp.doc.get_elements_by_tag_name("responsegroup").inner_text
  end

  def test_browse_node_lookup_with_new_releases_response
    resp = Amazon::Associates.browse_node_lookup("5", :response_group => "NewReleases")
    assert resp.request_valid?
    assert_equal "NewReleases", resp.doc.get_elements_by_tag_name("responsegroup").inner_text
  end

  def test_browse_node_lookup_with_invalid_request
    resp = Amazon::Associates.browse_node_lookup(nil)
    assert resp.has_error?
    assert resp.error
  end

  def test_browse_node_lookup_with_no_result
    resp = Amazon::Associates.browse_node_lookup("abc")

    assert resp.request_valid?
    assert_match(/abc is not a valid value for BrowseNodeId/, resp.error)
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
