require File.dirname(__FILE__) + '/../test_helper'

class Amazon::EcsTest < Test::Unit::TestCase

  AWS_ACCESS_KEY_ID = '0PP7FTN6FM3BZGGXJWG2'
  raise "Please specify set your AWS_ACCESS_KEY_ID" if AWS_ACCESS_KEY_ID.empty?
  
  Amazon::Ecs.configure do |options|
    options[:response_group] = 'Large'
    options[:aWS_access_key_id] = AWS_ACCESS_KEY_ID
  end

  ## Test item_search

  def test_item_search
    resp = Amazon::Ecs.item_search('ruby')
    assert(resp.is_valid_request?)
    assert(resp.total_results >= 3600)
    assert(resp.total_pages >= 360)
  end

  def test_item_search_with_paging
    resp = Amazon::Ecs.item_search('ruby', :item_page => 2)
    assert resp.is_valid_request?
    assert 2, resp.item_page
  end

  def test_item_search_with_invalid_request
    resp = Amazon::Ecs.item_search(nil)
    assert !resp.is_valid_request?
  end

  def test_item_search_with_no_result
    resp = Amazon::Ecs.item_search('afdsafds')
    
    assert resp.is_valid_request?
    assert_equal "We did not find any matches for your request.", 
      resp.error
  end
  
  def test_item_search_uk
    resp = Amazon::Ecs.item_search('ruby', :country => :uk)
    assert resp.is_valid_request?
  end
  
  def test_item_search_by_author
    resp = Amazon::Ecs.item_search('dave', :type => :author)
    assert resp.is_valid_request?
  end
  
  def test_item_get
    resp = Amazon::Ecs.item_search("0974514055")
    item = resp.items.first
        
    # test get
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", 
      item.get("itemattributes/title")
      
    # test get_array
    assert_equal ['Dave Thomas', 'Chad Fowler', 'Andy Hunt'], 
      (item/"author").to_a

    # test get_hash
    small_image = item.get_hash("smallimage")
    
    assert_equal 3, small_image.keys.size
    assert_equal "http://ecx.images-amazon.com/images/I/01H909PG5YL.jpg", small_image[:url]
    assert_equal "75", small_image[:height]
    assert_equal "59", small_image[:width]
    
    # test /
    (item/"editorialreview").each do |review|
      # returns unescaped HTML content, Hpricot escapes all text values
      assert review.get_unescaped('source')
      assert review.get_unescaped('content')
    end
  end
  
  ## Test item_lookup
  def test_item_lookup
    resp = Amazon::Ecs.item_lookup('0974514055')
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", 
    resp.items.first.get("itemattributes/title")
  end
  
  def test_item_lookup_with_invalid_request
    resp = Amazon::Ecs.item_lookup(nil)
    assert resp.has_error?
    assert resp.error
  end

  def test_item_lookup_with_no_result
    resp = Amazon::Ecs.item_lookup('abc')
    
    assert resp.is_valid_request?
    assert_match(/ABC is not a valid value for ItemId/, resp.error)
  end  
  
  def test_hpricot_extensions
    resp = Amazon::Ecs.item_lookup('0974514055')
    title = resp.items.first.get("itemattributes/title")
    authors = resp.items.first/"author"
    
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", title
    assert authors.is_a?(Array)
    assert 3, authors.size
    assert_equal "Dave Thomas", authors.first.get
  end  
end