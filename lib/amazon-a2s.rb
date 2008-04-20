%w(extensions/pp requests/cart requests/browse_node requests/item).each do |file|
  require File.join(File.dirname(__FILE__), 'amazon-a2s', file)
end

module Amazon
  class A2s
    # Default search options
    @options = {}
    @debug = false

    # see http://railstips.org/2006/11/18/class-and-instance-variables-in-ruby
    class << self;
      attr_accessor :debug
      attr_writer :options

      def options
        if access_key = @options.delete(:aws_access_key_id)
          @options[:aWS_access_key_id] = access_key
        end
        @options
      end

      SORT_TYPES = {
        'All' => nil,
	      'Apparel' => %w[relevancerank salesrank pricerank inverseprice -launch-date sale-flag],
	      'Automotive' => %w[salesrank price -price titlerank -titlerank],
	      'Baby' => %w[psrank salesrank price -price titlerank],
	      'Beauty' => %w[pmrank salesrank price -price -launch-date sale-flag],
	      'Books' => %w[relevancerank salesrank reviewrank pricerank inverse-pricerank daterank titlerank -titlerank],
	      'Classical' => %w[psrank salesrank price -price titlerank -titlerank orig-rel-date],
	      'DigitalMusic' => %w[songtitlerank uploaddaterank],
	      'DVD' => %w[relevancerank salesrank price -price titlerank -video-release-date],
	      'Electronics' => %w[pmrank salesrank reviewrank price -price titlerank],
	      'GourmetFood' => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
	      'HealthPersonalCare' => %w[pmrank salesrank pricerank inverseprice launch-date sale-flag],
	      'Jewelry' => %w[pmrank salesrank pricerank inverseprice launch-date],
	      'Kitchen' => %w[pmrank salesrank price -price titlerank -titlerank],
	      'Magazines' => %w[subslot-salesrank reviewrank price -price daterank titlerank -titlerank],
        'Marketplace' => nil,
	      'Merchants' => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
	      'Miscellaneous' => %w[pmrank salesrank price -price titlerank -titlerank],
	      'Music' => %w[psrank salesrank price -price titlerank -titlerank artistrank orig-rel-date release-date],
	      'MusicalInstruments' => %w[pmrank salesrank price -price -launch-date sale-flag],
	      'MusicTracks' => %w[titlerank -titlerank],
	      'OfficeProducts' => %w[pmrank salesrank reviewrank price -price titlerank],
	      'OutdoorLiving' => %w[psrank salesrank price -price titlerank -titlerank],
	      'PCHardware' => %w[psrank salesrank price -price titlerank],
	      'PetSupplies' => %w[+pmrank salesrank price -price titlerank -titlerank],
	      'Photo' => %w[pmrank salesrank titlerank -titlerank],
	      'Restaurants' => %w[relevancerank titlerank],
	      'Software' => %w[pmrank salesrank titlerank price -price],
	      'SportingGoods' => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
	      'Tools' => %w[pmrank salesrank titlerank -titlerank price -price],
	      'Toys' => %w[pmrank salesrank price -price titlerank -age-min],
	      'VHS' => %w[relevancerank salesrank price -price titlerank -video-release-date],
	      'Video' => %w[relevancerank salesrank price -price titlerank -video-release-date],
	      'VideoGames' => %w[pmrank salesrank price -price titlerank],
	      'Wireless' => %w[daterank pricerank invers-pricerank reviewrank salesrank titlerank -titlerank],
	      'WirelessAccessories' => %w[psrank salesrank titlerank -titlerank]
	    }.freeze
      def sort_types
        SORT_TYPES
      end

      SEARCH_INDEXES = SORT_TYPES.keys.sort.freeze
      def search_indexes
        SEARCH_INDEXES
      end

      # TODO: Default to blended?  Don't show others except on refined search page?
      def default_search_index
        'Books'
      end
    end

  protected
    def self.log(s)
      return unless debug
      if defined? RAILS_DEFAULT_LOGGER
        RAILS_DEFAULT_LOGGER.error(s)
      elsif defined? LOGGER
        LOGGER.error(s)
      else
        puts s
      end
    end
  end
end
