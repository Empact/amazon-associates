dirname = File.dirname(__FILE__) 
require File.join(dirname, '../test_helper')
require File.join(dirname, '../../lib/amazon-a2s')

class Amazon::A2sTest < Test::Unit::TestCase

  AWS_ACCESS_KEY_ID = '0PP7FTN6FM3BZGGXJWG2'
  raise "Please specify set your AWS_ACCESS_KEY_ID" if AWS_ACCESS_KEY_ID.empty?
  
  Amazon::A2s.options.merge!(
    :response_group    => 'Large',
    :aws_access_key_id => AWS_ACCESS_KEY_ID)

  ## Test item_search

  def test_item_search
    resp = Amazon::A2s.item_search('ruby')
    assert(resp.valid_request?)
    assert(resp.total_results >= 3600)
    assert(resp.total_pages >= 360)
  end

  def test_item_search_with_paging
    resp = Amazon::A2s.item_search('ruby', :item_page => 2)
    assert resp.valid_request?
    assert 2, resp.item_page
  end

  def test_item_search_with_invalid_request
    assert_raise Amazon::RequiredParameterMissing do
      Amazon::A2s.item_search(nil)
    end
  end

  def test_item_search_with_no_result
    assert_raise Amazon::ItemNotFound, ' We did not find any matches for your request.' do
      Amazon::A2s.item_search('afdsafds')
    end
  end
  
  def test_item_search_uk
    resp = Amazon::A2s.item_search('ruby', :country => :uk)
    assert resp.valid_request?
  end
  
  def test_item_search_not_keywords
    resp = Amazon::A2s.item_search(:author => 'rowling')
    assert resp.valid_request?
  end
  
  def test_item_search_fake_country_should_throw
    assert_raise Amazon::RequestError do
      Amazon::A2s.item_search('ruby', :country => :asfdkjjk)
    end
  end
  
  def test_item_search_by_author
    resp = Amazon::A2s.item_search('dave', :type => :author)
    assert resp.valid_request?
  end
  
  def test_text_at
    item = Amazon::A2s.item_search("0974514055").items.first
    
    # one item
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", 
      item.text_at("itemattributes/title")
      
    # multiple items
    assert_equal ['Dave Thomas', 'Chad Fowler', 'Andy Hunt'], 
      item.texts_at("author")
      
    #ordinals
    assert_equal Amazon::Ordinal.new(2), item.hash_at('edition')
  end

  def test_hash_at_handles_specific_types
    item = Amazon::A2s.item_search('ipod', :search_index => 'Merchants', :response_group => 'Small,Offers,ItemAttributes,VariationSummary,Images').items.first
    
    # Measurements & Image
    assert_equal(Amazon::Image.new("http://ecx.images-amazon.com/images/I/01Hwx6M-XEL.jpg",
														      Amazon::Measurement.new(62, 'pixels'),
														      Amazon::Measurement.new(75, 'pixels')),
      item.hash_at("smallimage"))
    
    assert_equal "62x75", item.hash_at("smallimage").size
    
    # bools
    assert_equal true, item.bool_at('iseligibleforsupersavershipping')
    assert_equal false, item.bool_at('batteriesincluded')
    
    # price
    assert_equal Amazon::Price.new('$149.00', 14900, 'USD'), item.hash_at('listprice')
    
    # integers
    assert_instance_of Fixnum, item.hash_at('totalnew')
    assert_instance_of Fixnum, item.hash_at('totaloffers')
    
    # attributes
    assert_equal({:category=>"primary"}, item.hash_at('imageset')[:attributes])
    
    # ordinals
    # in test_text_at, above
  end
  
  def test_price_should_handle_Price_Too_Low_To_Display
    item = Amazon::A2s.item_lookup('B000W79GQA', :response_group => 'Small,Offers,ItemAttributes,VariationSummary,Images').items.first
    assert item.to_hash
  end
  
  def test_hash_at_handles_string_editions
    Amazon::A2s.item_search("potter", :item_page => 3, :response_group => 'Small,Offers,ItemAttributes,VariationSummary,Images').items.each do |item|
      assert item.to_hash
    end
  end
  
  def test_hash_at_makes_arrays_from_lists    
    item = Amazon::A2s.item_search("0974514055").items.first

    # when <listmanialists> contains a bunch of <listmanialist>s, return an array
    assert_equal({:listmanialist => [
                     {:listid=>"RCWKKCCVL5FGL",  :listname=>"Survey of programming languages/paradigms"},                     
                     {:listid=>"R2IJ2M3X3ITVAR", :listname=>"The path to enlightenment"},
                     {:listid=>"R3MGYO2P65FC8J", :listname=>"Ruby Books"},
                     {:listid=>"R3AEQKTMFEETCN", :listname=>"Ruby & Rails From Novice To Expert"},
                     {:listid=>"R2VY37TQWQM0VJ", :listname=>"Computer Science classics"},
                     {:listid=>"R3DB3MYO22PHZ6", :listname=>"Ruby for Linguistics"},
                     {:listid=>"R192F79G3UXHJ5", :listname=>"Programming Books"},
                     {:listid=>"R1L6QNM215M7FB", :listname=>"Ruby/Ruby on Rails"},
                     {:listid=>"RROZA1M8ZJVR2",  :listname=>"Some books on web development"},
                     {:listid=>"RDZIIJ8YUICL1",  :listname=>"Programmer's Companion"}]},
       item.hash_at('listmanialists'))
    
    # when there's a single child, make sure it's parsed rather than returned as a string
    assert_equal({:editorialreview=>
                      {:content=>
                        "Ruby is an increasingly popular, fully object-oriented dynamic programming language, hailed by many practitioners as the finest and most useful language available today.  When Ruby first burst onto the scene in the Western world, the Pragmatic Programmers were there with the definitive reference manual, <i>Programming Ruby: The Pragmatic Programmer's Guide</i>.<br /> <br /> Now in its second edition, author Dave Thomas has expanded the famous Pickaxe book with over 200 pages of new content, covering all the improved language features of Ruby 1.8 and standard library modules. The Pickaxe contains four major sections: <ul><li>An acclaimed tutorial on using Ruby. </li><li>The definitive reference to the language. </li><li>Complete documentation on all built-in classes, modules, and methods </li><li>Complete descriptions of all 98 standard libraries.</li></ul><br /> <br /> If you enjoyed the First Edition, you'll appreciate the expanded content, including enhanced coverage of installation, packaging, documenting Ruby source code, threading and synchronization, and enhancing Ruby's capabilities using C-language extensions. Programming for the World Wide Web is easy in Ruby, with new chapters on XML/RPC, SOAP, distributed Ruby, templating systems, and other web services.  There's even a new chapter on unit testing.<br /> <br /> This is the definitive reference manual for Ruby, including a description of all the standard library modules, a complete reference to all built-in classes and modules (including more than 250 significant changes since the First Edition). Coverage of other features has grown tremendously, including details on how to harness the sophisticated capabilities of irb, so you can dynamically examine and experiment with your running code. \"Ruby is a wonderfully powerful and useful language, and whenever I'm working with it this book is at my side\" --Martin Fowler, Chief Scientist, ThoughtWorks",
                       :source=>"Book Description"}},
      item.hash_at('editorialreviews'))
  end

  def test_unescaped_at
    item = Amazon::A2s.item_search("0974514055").items.first
      
    item.search("editorialreview").each do |review|
      # returns unescaped HTML content, Hpricot escapes all text values
      assert review.unescaped_at('source')
      assert review.unescaped_at('content')
    end
  end
  
  ## Test item_lookup
  def test_item_lookup
    resp = Amazon::A2s.item_lookup('0974514055')
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", 
    resp.items.first.text_at("itemattributes/title")
  end
  
  def test_item_lookup_with_invalid_request
    assert_raise Amazon::RequiredParameterMissing, 'Your request is missing required parameters. Required parameters include ItemId.' do
      Amazon::A2s.item_lookup(nil)
    end
  end

  def test_item_lookup_with_no_result
    assert_raise Amazon::InvalidParameterValue, 'ABC is not a valid value for ItemId. Please change this value and retry your request.' do
      Amazon::A2s.item_lookup('abc')
    end
  end
  
  def test_top_sellers
    assert !Amazon::A2s.browse_node_lookup(:response_group => 'TopSellers', :browse_node_id => 493964).top_sellers.empty?
  end
  
  def test_browsenodes
    item = Amazon::A2s.item_lookup('B000ROI682', :response_group => 'BrowseNodes').items.first
    browsenodes = item.hash_at('browsenodes')[:browsenode]
    assert browsenodes.size > 1 
    browsenodes.each do |browsenode|
      assert_kind_of Amazon::BrowseNode, browsenode
      assert (browsenode.type? or browsenode.brand?), browsenode.to_s
    end
  end
  
  def test_hpricot_extensions
    resp = Amazon::A2s.item_lookup('0974514055')
    title = resp.items.first.text_at("itemattributes/title")
    authors = resp.items.first/"author"
    
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", title
    assert authors.is_a?(Array)
    assert 3, authors.size
    assert_equal "Dave Thomas", authors.first.to_text
  end  
end