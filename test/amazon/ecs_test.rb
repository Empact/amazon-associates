dirname = File.dirname(__FILE__) 
require File.join(dirname, '../test_helper')
require File.join(dirname, '../../lib/amazon/ecs')

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
  
  def test_item_search_fake_country_should_throw
    assert_raises Amazon::RequestError do
      Amazon::Ecs.item_search('ruby', :country => :asfdkjjk)
    end
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
      item.get("author")

    # test get_hash
    assert_equal({:url => "http://ecx.images-amazon.com/images/I/01H909PG5YL.jpg",
                  :height => {:value => "75", :attributes => {:units => 'pixels'}},
                  :width => {:value => "59", :attributes => {:units => 'pixels'}}},
      item.get_hash("smallimage"))
    
    # when <listmanialists> contains a bunch of <listmanialist>s, return an array
    assert_equal [{:listid => "R2IJ2M3X3ITVAR", :listname => "The path to enlightenment"},
                  {:listid => "R3MGYO2P65FC8J", :listname => "Ruby Books"},
                  {:listid => "R3AEQKTMFEETCN", :listname => "Ruby &amp; Rails From Novice To Expert"},
                  {:listid => "R2VY37TQWQM0VJ", :listname => "Computer Science classics"},
                  {:listid => "R3DB3MYO22PHZ6", :listname => "Ruby for Linguistics"},
                  {:listid => "R192F79G3UXHJ5", :listname => "Programming Books"},
                  {:listid => "R1L6QNM215M7FB", :listname => "Ruby/Ruby on Rails"},
                  {:listid => "RROZA1M8ZJVR2",  :listname => "Some books on web development"},
                  {:listid => "RDZIIJ8YUICL1",  :listname => "Programmer's Companion"},
                  {:listid => "R26F0LAW83WGCD", :listname => "Starting a software company"} ],
      item.get_hash('listmanialists')

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