require File.join(File.dirname(__FILE__), '../test_helper')

module Amazon
  module Associates
    class ItemTest < Test::Unit::TestCase
      include FilesystemTestHelper
      
      ## Test item_search
      def setup
        set_valid_caching_options
        @ruby_search = Amazon::Associates.item_search('ruby')
      end

      def test_item_search
        assert @ruby_search.request.valid?
        assert @ruby_search.total_results >= 3600
        assert @ruby_search.total_pages >= 360
      end

      def test_page_should_be_one_for_first_page
        assert_equal 1, @ruby_search.current_page
      end

      def test_item_search_response_type
        assert_equal ItemSearchResponse, @ruby_search.class
      end

      def test_argument_hash
        assert_equal Hash, @ruby_search.operation_request.arguments.class
      end

      def test_item_search_with_paging
        resp = Amazon::Associates.item_search('ruby', :item_page => 2)
        assert resp.request.valid?
        assert 2, resp.current_page
      end

      def test_item_search_with_response_group_array
        resp = Amazon::Associates.item_search('ruby', :response_group => %w{Small ItemAttributes Images})
        assert resp.request.valid?
      end

      def test_item_search_with_invalid_request
        assert_raise Amazon::Associates::RequiredParameterMissing do
          Amazon::Associates.item_search(nil)
        end
      end

      def test_item_search_with_no_result
        assert_raise Amazon::Associates::ItemNotFound, ' We did not find any matches for your request.' do
          Amazon::Associates.item_search('afdsafds')
        end
      end

      def test_item_search_uk
        resp = Amazon::Associates.item_search('ruby', :country => 'uk')
        assert resp.request.valid?
      end

      def test_item_search_not_keywords
        resp = Amazon::Associates.item_search(:author => 'rowling')
        assert resp.request.valid?
      end

      def test_item_search_fake_country_should_throw
        assert_raise Amazon::Associates::RequestError do
          Amazon::Associates.item_search('ruby', :country => :asfdkjjk)
        end
      end

      def test_item_search_by_author
        resp = Amazon::Associates.item_search('dave', :type => :author)
        assert resp.request.valid?
      end

      def test_text_at
        item = Amazon::Associates.item_search("0974514055", :response_group => 'Large').items.first

        # one item
        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition",
          item.attributes['Title']

        # multiple items
        assert_equal ['Dave Thomas', 'Chad Fowler', 'Andy Hunt'],
          item.authors

        #ordinals
        assert_equal Amazon::Associates::Ordinal.new(2), item.edition
      end

      def test_item_search_should_handle_string_argument_keys_as_well_as_symbols
        Amazon::Associates.item_search('potter', 'search_index' => 'Books')
      end

      def test_hash_at_handles_specific_types
        item = Amazon::Associates.item_search('ipod', :search_index => 'All', :response_group => 'Small,Offers,ItemAttributes,VariationSummary,Images,BrowseNodes').items.first

        # Measurements & Image
        assert_equal(Amazon::Associates::Image.new("http://ecx.images-amazon.com/images/I/41zt-RXYhfL._SL75_.jpg",
            Amazon::Associates::Measurement.new(56, 'pixels'),
            Amazon::Associates::Measurement.new(75, 'pixels')),
          item.small_image)

        # bools
        assert !item.offers.empty?
        assert_equal true, item.offers.first.is_eligible_for_super_saver_shipping?
        assert_equal false, item.batteries_included?

        # price
        assert_equal Amazon::Associates::Price.new('$249.99', 24999, 'USD'), item.list_price

        # integers
        assert_instance_of Fixnum, item.total_new_offers
        assert_instance_of Fixnum, item.total_offers

        # attributes
        assert item.image_sets['primary'], item.image_sets.inspect
        assert_equal "Mary GrandPré", Amazon::Associates.item_lookup('0545010225').item.creators['Illustrator']

        # browsenodes
        nodes = item.browse_nodes.detect {|n| n.name == 'MP3 Players' }
        assert_equal 'MP3 Players', nodes.name
        assert_equal 'Audio & Video', nodes.parent.name
        assert_equal 'Apple', nodes.parent.parent.name
        assert_equal 'Custom Brands', nodes.parent.parent.parent.name

        # ordinals
        # in test_text_at, above
      end

      def test_price_should_handle_price_too_low_to_display
        assert_equal 'Too low to display', Amazon::Associates.item_lookup('B000W79GQA', :response_group => 'Offers').item.lowest_new_price.to_s
      end

      def test_hash_at_handles_string_editions
        Amazon::Associates.item_search("potter", :item_page => 3, :response_group => 'Small,Offers,ItemAttributes,VariationSummary,Images').items.each do |item|
          assert item
        end
      end

      def test_hash_at_makes_arrays_from_lists
        item = Amazon::Associates.item_search("0974514055", :response_group => 'Large').items.first

        # when <listmanialists> contains a bunch of <listmanialist>s, return an array
        assert_equal(["R35BVGTHX7WEKZ",  "R195F9SN6I3YQH",  "R14L8RHCLAYQMY",  "RCWKKCCVL5FGL",  "R2IJ2M3X3ITVAR",
            "R3MGYO2P65FC8J",  "R2VY37TQWQM0VJ",  "R3DB3MYO22PHZ6",  "R192F79G3UXHJ5",  "R1L6QNM215M7FB"],
          item.listmania_lists.map(&:id))

        review = item.editorial_reviews.first
        # when there's a single child, make sure it's parsed rather than returned as a string
        assert_equal "Product Description", review.source
        assert review.content.is_a?(String)
        assert review.content.size > 100
        assert review.content.starts_with?("Ruby is an increasingly popular, fully object-oriented d")
      end

      ## Test item_lookup
      def test_item_lookup
        resp = Amazon::Associates.item_lookup('0974514055')
        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition",
          resp.item.attributes['Title']
      end

      def test_item_lookup_with_invalid_request
        assert_raise Amazon::Associates::RequiredParameterMissing, 'Your request is missing required parameters. Required parameters include ItemId.' do
          Amazon::Associates.item_lookup(nil)
        end
      end

      def test_item_lookup_with_no_result
        assert_raise Amazon::Associates::InvalidParameterValue, 'ABC is not a valid value for ItemId. Please change this value and retry your request.' do
          resp = Amazon::Associates.item_lookup('abc')
          raise resp.inspect
        end
      end

      def test_hpricot_extensions
        item = Amazon::Associates.item_lookup('0974514055').item

        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", item.attributes['Title']
        assert item.authors.is_a?(Array)
        assert 3, item.authors.size
        assert_equal "Dave Thomas", item.authors.first
      end
    end

    class Amazon::Associates::ItemTestsBroughtInFromAssociateGem < Test::Unit::TestCase
      include FilesystemTestHelper
      
      def setup
        set_valid_caching_options
        Amazon::Associates.options.merge!(:response_group => "Large")
      end

      ## Test item_search
      def test_item_search
        resp = Amazon::Associates.item_search("ruby")
        assert(resp.request.valid?)
        assert(resp.total_results >= 3600)
        assert(resp.total_pages >= 360)
      end

      def test_item_search_with_paging
        resp = Amazon::Associates.item_search("ruby", :item_page => 2)
        assert resp.request.valid?
        assert 2, resp.current_page
      end

      def test_item_search_with_invalid_request
        assert_raise(Amazon::Associates::RequiredParameterMissing) do
          Amazon::Associates.item_search(nil)
        end
      end

      def test_item_search_with_no_result
        assert_raise(Amazon::Associates::ItemNotFound) do
          Amazon::Associates.item_search("afdsafds")
        end
      end

      def test_item_search_uk
        resp = Amazon::Associates.item_search("ruby", :country => :uk)
        assert resp.request.valid?
      end

      def test_item_search_by_author
        resp = Amazon::Associates.item_search("dave", :type => :author)
        assert resp.request.valid?
      end

      def test_item_get
        resp = Amazon::Associates.item_search("0974514055")
        item = resp.items.first

        # test get
        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition",
          item.attributes['Title']

        # test get_array
        assert_equal ['Dave Thomas', 'Chad Fowler', 'Andy Hunt'], item.authors

        # test get_hash
        small_image = item.image_sets.values.first.small

        assert small_image.url != nil
        assert_equal 75, small_image.height.value
        assert_equal 59, small_image.width.value
      end

      ## Test item_lookup
      def test_item_lookup
        resp = Amazon::Associates.item_lookup("0974514055")
        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition",
        resp.items.first.attributes['Title']
      end

      def test_item_lookup_with_invalid_request
        assert_raise(Amazon::Associates::RequiredParameterMissing) do
          Amazon::Associates.item_lookup(nil)
        end
      end

      def test_item_lookup_with_no_result
        assert_raise(Amazon::Associates::InvalidParameterValue) do
          resp = Amazon::Associates.item_lookup("abc")
        end
      end

      def test_search_and_convert
        resp = Amazon::Associates.item_lookup("0974514055")
        title = resp.items.first.attributes['Title']
        authors = resp.items.first.authors

        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", title
        assert authors.is_a?(Array)
        assert 3, authors.size
        assert_equal "Dave Thomas", authors.first
      end
    end

    class ItemTestBroughtIn < Test::Unit::TestCase
      include FilesystemTestHelper
      
      def setup
        set_valid_caching_options
      end

      def test_find_all_should_return_items
        item = Item.find(:all, :keywords => 'upside').first
        assert item
        assert_kind_of Item, item
      end

      def test_find_all_and_find_first_should_yield_same_first
        params = {:keywords => 'jelly'}
        assert_equal Item.find(:all, params).first, Item.find(:first, params)
      end

      def test_find_second_page_returns_different_items_than_first
        params = {:keywords => 'potter'}
        assert_not_equal Item.find(:first, params.merge(:page => 1)),
          Item.find(:first, params.merge(:page => 2))
      end

      def test_item_creator_should_be_unpacked
        p "Pending: we're losing info from attributes..."
#        asin = '0545010225'
#        item = Item.find(asin)
#        assert_equal("Mary GrandPré",
#          Amazon::Associates.item_lookup(asin).items.first.attributes["Creator"])
      end

      def test_item_list_price_present
        assert Item.find('0545010225').list_price
      end

      def test_item_performers_unpacked_to_array
        assert_equal(["Robert Downey Jr.", "Gwyneth Paltrow", "Terrence Howard", "Jeff Bridges", "Leslie Bibb"],
          Item.find('B00005JPS8').attributes['Actor'])
      end

      def test_image_sets_should_be_unpacked
        item = Item.find(:first, :keywords => 'potter')
        assert !item.image_sets.empty?
      end

      def test_missing_item_should_throw
        assert_raise Amazon::Associates::InvalidParameterValue do
          Item.find('abc')
        end
      end

      def test_find_no_page_returns_same_items_as_first
        params = {:keywords => 'potter'}
        assert_equal Item.find(:first, params),
          Item.find(:first, params.merge(:page => 1))
      end

      def test_find_with_different_sort_returns_different
        params = {:keywords => 'potter'}
        assert_not_equal Item.find(:first, params.merge(:sort => Amazon::Associates.sort_types['Books'][3])),
          Item.find(:first, params.merge(:sort => Amazon::Associates.sort_types['Books'][7]))
        assert_equal Item.find(:first, params.merge(:sort => Amazon::Associates.sort_types['Books'][3])),
          Item.find(:first, params.merge(:sort => Amazon::Associates.sort_types['Books'][3]))
      end

      def test_find_too_far_a_page_is_error
        assert_raise Amazon::Associates::ParameterOutOfRange do
          Item.find(:first, :keywords => 'potter', :page => 9999)
        end
      end

      def test_none_found_is_error
        assert_raise Amazon::Associates::ItemNotFound do
          Item.find(:first, :keywords => 'zjvalk', :page => 400)
        end
      end

      def test_pagination_basics
        results = Item.find(:all, :keywords => 'potter', :search_index => 'All')
        assert_equal 4000, results.total_entries
        assert_equal 1, results.current_page
      end

      def test_pagination_sets_current_page
        [3, 7].each do |page|
          assert_equal page, Item.find(:all, :keywords => 'potter', :page => page).current_page
        end
      end

      def test_should_reject_unknown_args
        assert_raise ArgumentError do
          Item.find(:first, :keywords => 'potter', :itempage => 12)
        end
      end

      def test_find_should_work_for_blended_merchants_and_all
        assert Item.find(:first, :keywords => 'blackberry', :search_index => 'Blended')
        assert Item.find(:first, :keywords => 'blackberry', :search_index => 'All')
        assert Item.find(:first, :keywords => 'blackberry', :search_index => 'Merchants')
      end

      def test_find_top_sellers_should_return_items
        assert !Item.find(:top_sellers, :browse_node_id => 520432).empty?
      end

      def test_should_find_one
        item_asin = '0545010225'
        item = Item.find(item_asin)
        assert item
        assert item.is_a?(Item)
        assert_equal item_asin, item.asin
      end

      def test_find_one_and_first_should_be_equivalent
        # TODO: or maybe a subset?
        item1 = Item.find(:first, :keywords => 'potter')
        item2 = Item.find(item1.asin)
        assert_equal item1, item2
      end

      def test_should_raise_on_bad_request
        assert_raise ArgumentError do
          Item.find(20)
        end
      end
    end
  end
end