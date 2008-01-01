dirname = File.dirname(__FILE__) 
require File.join(dirname, '../test_helper')
require File.join(dirname, '../../lib/amazon/a2s')

class Amazon::EcsTest < Test::Unit::TestCase

  AWS_ACCESS_KEY_ID = '0PP7FTN6FM3BZGGXJWG2'
  raise "Please specify set your AWS_ACCESS_KEY_ID" if AWS_ACCESS_KEY_ID.empty?
  
  Amazon::Ecs.options.merge!(
    :response_group    => 'Large',
    :aWS_access_key_id => AWS_ACCESS_KEY_ID)

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
    assert_raise Amazon::RequiredParameterMissing do
      Amazon::Ecs.item_search(nil)
    end
  end

  def test_item_search_with_no_result
    assert_raise Amazon::ItemNotFound, ' We did not find any matches for your request.' do
      Amazon::Ecs.item_search('afdsafds')
    end
  end
  
  def test_item_search_uk
    resp = Amazon::Ecs.item_search('ruby', :country => :uk)
    assert resp.is_valid_request?
  end
  
  def test_item_search_fake_country_should_throw
    assert_raise Amazon::RequestError do
      Amazon::Ecs.item_search('ruby', :country => :asfdkjjk)
    end
  end
  
  def test_item_search_by_author
    resp = Amazon::Ecs.item_search('dave', :type => :author)
    assert resp.is_valid_request?
  end
  
  def test_item_get
    item = Amazon::Ecs.item_search("0974514055").items.first
    
    # one item
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", 
      item.get("itemattributes/title")
      
    # multiple items
    assert_equal ['Dave Thomas', 'Chad Fowler', 'Andy Hunt'], 
      item.get("author")
  end

  def test_get_hash_handles_attributes
    item = Amazon::Ecs.item_search("0974514055").items.first

    assert_equal({:url => "http://ecx.images-amazon.com/images/I/01H909PG5YL.jpg",
                  :height => {:value => "75", :attributes => {:units => 'pixels'}},
                  :width => {:value => "59", :attributes => {:units => 'pixels'}}},
      item.get_hash("smallimage"))
  end
  
  def test_get_hash_makes_arrays_from_lists    
    item = Amazon::Ecs.item_search("0974514055").items.first

    # when <listmanialists> contains a bunch of <listmanialist>s, return an array
    assert_equal({:listmanialist => [
                     {:listid=>"R2IJ2M3X3ITVAR", :listname=>"The path to enlightenment"},
                     {:listid=>"R3MGYO2P65FC8J", :listname=>"Ruby Books"},
                     {:listid=>"R3AEQKTMFEETCN", :listname=>"Ruby & Rails From Novice To Expert"},
                     {:listid=>"R2VY37TQWQM0VJ", :listname=>"Computer Science classics"},
                     {:listid=>"R3DB3MYO22PHZ6", :listname=>"Ruby for Linguistics"},
                     {:listid=>"R192F79G3UXHJ5", :listname=>"Programming Books"},
                     {:listid=>"R1L6QNM215M7FB", :listname=>"Ruby/Ruby on Rails"},
                     {:listid=>"RROZA1M8ZJVR2",  :listname=>"Some books on web development"},
                     {:listid=>"RDZIIJ8YUICL1",  :listname=>"Programmer's Companion"},
                     {:listid=>"R26F0LAW83WGCD", :listname=>"Starting a software company"}]},
       item.get_hash('listmanialists'))
    
    # when there's a single child, make sure it's parsed rather than returned as a string
    assert_equal({:editorialreview=>
                      {:content=>
                        "Ruby is an increasingly popular, fully object-oriented dynamic programming language, hailed by many practitioners as the finest and most useful language available today.  When Ruby first burst onto the scene in the Western world, the Pragmatic Programmers were there with the definitive reference manual, <i>Programming Ruby: The Pragmatic Programmer's Guide</i>.<br /> <br /> Now in its second edition, author Dave Thomas has expanded the famous Pickaxe book with over 200 pages of new content, covering all the improved language features of Ruby 1.8 and standard library modules. The Pickaxe contains four major sections: <ul><li>An acclaimed tutorial on using Ruby. </li><li>The definitive reference to the language. </li><li>Complete documentation on all built-in classes, modules, and methods </li><li>Complete descriptions of all 98 standard libraries.</li></ul><br /> <br /> If you enjoyed the First Edition, you'll appreciate the expanded content, including enhanced coverage of installation, packaging, documenting Ruby source code, threading and synchronization, and enhancing Ruby's capabilities using C-language extensions. Programming for the World Wide Web is easy in Ruby, with new chapters on XML/RPC, SOAP, distributed Ruby, templating systems, and other web services.  There's even a new chapter on unit testing.<br /> <br /> This is the definitive reference manual for Ruby, including a description of all the standard library modules, a complete reference to all built-in classes and modules (including more than 250 significant changes since the First Edition). Coverage of other features has grown tremendously, including details on how to harness the sophisticated capabilities of irb, so you can dynamically examine and experiment with your running code. \"Ruby is a wonderfully powerful and useful language, and whenever I'm working with it this book is at my side\" --Martin Fowler, Chief Scientist, ThoughtWorks",
                       :source=>"Book Description"}},
      item.get_hash('editorialreviews'))
  end

  def test_get_unescaped
    item = Amazon::Ecs.item_search("0974514055").items.first
      
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
    assert_raise Amazon::RequiredParameterMissing, 'Your request is missing required parameters. Required parameters include ItemId.' do
      Amazon::Ecs.item_lookup(nil)
    end
  end

  def test_item_lookup_with_no_result
    assert_raise Amazon::InvalidParameterValue, 'ABC is not a valid value for ItemId. Please change this value and retry your request.' do
      Amazon::Ecs.item_lookup('abc')
    end
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