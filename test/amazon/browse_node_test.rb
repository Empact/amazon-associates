require File.join(File.dirname(__FILE__), '../test_helper')

class Amazon::A2s::BrowseNodeTest < Test::Unit::TestCase
	def test_browsenodes
	  item = Amazon::A2s.item_lookup('B000ROI682', :response_group => 'BrowseNodes').items.first
	  browsenodes = item.hash_at('browsenodes')
	  assert browsenodes.size > 1 
	  browsenodes.each do |browsenode|
	    assert_kind_of Amazon::BrowseNode, browsenode
	    assert !browsenode.to_s.include?('&amp;'), browsenode.to_s
	  end
	end

  def test_top_sellers
    assert !Amazon::A2s.browse_node_lookup(:response_group => 'TopSellers', :browse_node_id => 493964).top_sellers.empty?
  end  
end