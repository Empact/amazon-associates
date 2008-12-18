require File.join(File.dirname(__FILE__), '../test_helper')

module Amazon
  class A2s
    class ItemTest < Test::Unit::TestCase
      ## Test item_search
      def setup
        @ruby_search = Amazon::A2s.item_search('ruby')
      end

      def test_item_search
        assert @ruby_search.request.valid?
        assert @ruby_search.total_results >= 3600
        assert @ruby_search.total_pages >= 360
      end

      def test_page_should_be_one_for_first_page
        assert_equal 1, @ruby_search.page
      end

      def test_item_search_response_type
        assert_equal ItemSearchResponse, @ruby_search.class
      end

      def test_argument_hash
        assert_equal Hash, @ruby_search.operation_request.arguments.class
      end

      def test_item_search_with_paging
        resp = Amazon::A2s.item_search('ruby', :item_page => 2)
        assert resp.request.valid?
        assert 2, resp.page
      end

      def test_item_search_with_response_group_array
        resp = Amazon::A2s.item_search('ruby', :response_group => %w{Small ItemAttributes Images})
        assert resp.request.valid?
      end

      def test_item_search_with_invalid_request
        assert_raise Amazon::A2s::RequiredParameterMissing do
          Amazon::A2s.item_search(nil)
        end
      end

      def test_item_search_with_no_result
        assert_raise Amazon::A2s::ItemNotFound, ' We did not find any matches for your request.' do
          Amazon::A2s.item_search('afdsafds')
        end
      end

      def test_item_search_uk
        resp = Amazon::A2s.item_search('ruby', :country => 'uk')
        assert resp.request.valid?
      end

      def test_item_search_not_keywords
        resp = Amazon::A2s.item_search(:author => 'rowling')
        assert resp.request.valid?
      end

      def test_item_search_fake_country_should_throw
        assert_raise Amazon::A2s::RequestError do
          Amazon::A2s.item_search('ruby', :country => :asfdkjjk)
        end
      end

      def test_item_search_by_author
        resp = Amazon::A2s.item_search('dave', :type => :author)
        assert resp.request.valid?
      end

      def test_text_at
        item = Amazon::A2s.item_search("0974514055", :response_group => 'Large').items.first

        # one item
        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition",
          item.attributes['Title']

        # multiple items
        assert_equal ['Dave Thomas', 'Chad Fowler', 'Andy Hunt'],
          item.authors

        #ordinals
        assert_equal Amazon::Ordinal.new(2), item.edition
      end

      def test_item_search_should_handle_string_argument_keys_as_well_as_symbols
        Amazon::A2s.item_search('potter', 'search_index' => 'Books')
      end

      def test_hash_at_handles_specific_types
        item = Amazon::A2s.item_search('ipod', :search_index => 'All', :response_group => 'Small,Offers,ItemAttributes,VariationSummary,Images,BrowseNodes').items.first

        # Measurements & Image
        assert_equal(Amazon::Image.new("http://ecx.images-amazon.com/images/I/41qEH4hLTRL._SL75_.jpg",
                                      Amazon::Measurement.new(56, 'pixels'),
                                      Amazon::Measurement.new(75, 'pixels')),
          item.small_image)

        assert_equal "56x75", item.small_image.size

        # bools
        assert !item.offers.empty?
        assert_equal true, item.offers.first.is_eligible_for_super_saver_shipping?
        assert_equal false, item.batteries_included?

        # price
        assert_equal Amazon::Price.new('$149.99', 14999, 'USD'), item.list_price

        # integers
        assert_instance_of Fixnum, item.total_new_offers
        assert_instance_of Fixnum, item.total_offers

        # attributes
        assert_equal "primary", item.image_sets.first.category
        assert_equal "Mary GrandPré", Amazon::A2s.item_lookup('0545010225').item.creators['Illustrator']

        # browsenodes
        nodes = item.browse_nodes.detect {|n| n.name == 'MP3 Players' }
        assert_equal 'MP3 Players', nodes.name
        assert_equal 'Audio & Video', nodes.parent.name
        assert_equal 'Apple', nodes.parent.parent.name
        assert_equal 'Custom Brands', nodes.parent.parent.parent.name

        # ordinals
        # in test_text_at, above
      end

      def test_price_should_handle_Price_Too_Low_To_Display
        assert_equal 'Too low to display', Amazon::A2s.item_lookup('B000W79GQA', :response_group => 'Offers').item.lowest_new_price.to_s
      end

      def test_hash_at_handles_string_editions
        Amazon::A2s.item_search("potter", :item_page => 3, :response_group => 'Small,Offers,ItemAttributes,VariationSummary,Images').items.each do |item|
          assert item
        end
      end

      def test_hash_at_makes_arrays_from_lists
        item = Amazon::A2s.item_search("0974514055", :response_group => 'Large').items.first

        # when <listmanialists> contains a bunch of <listmanialist>s, return an array
        assert_equal(["R195F9SN6I3YQH", "R14L8RHCLAYQMY", "RCWKKCCVL5FGL", "R2IJ2M3X3ITVAR", "R3MGYO2P65FC8J",
                      "R2VY37TQWQM0VJ", "R3DB3MYO22PHZ6", "R192F79G3UXHJ5",  "R1L6QNM215M7FB", "RROZA1M8ZJVR2"],
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
        resp = Amazon::A2s.item_lookup('0974514055')
        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition",
                     resp.item.attributes['Title']
      end

      def test_item_lookup_with_invalid_request
        assert_raise Amazon::A2s::RequiredParameterMissing, 'Your request is missing required parameters. Required parameters include ItemId.' do
          Amazon::A2s.item_lookup(nil)
        end
      end

      def test_item_lookup_with_no_result
        assert_raise Amazon::A2s::InvalidParameterValue, 'ABC is not a valid value for ItemId. Please change this value and retry your request.' do
          resp = Amazon::A2s.item_lookup('abc')
          raise resp.inspect
        end
      end

      def test_hpricot_extensions
        item = Amazon::A2s.item_lookup('0974514055').item

        assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", item.attributes['Title']
        assert item.authors.is_a?(Array)
        assert 3, item.authors.size
        assert_equal "Dave Thomas", item.authors.first
      end
    end
  end
end