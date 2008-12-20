require File.join(File.dirname(__FILE__), '../request')
require 'rubygems'
require 'will_paginate/collection'

module Amazon
  class A2s
    request :item_search => :keywords do |opts|
      opts[:search_index] ||= default_search_index
      opts
    end
    request :similarity_lookup => :item_id,
            :item_lookup => :item_id

    class Item
      PER_PAGE = 10
      MAX_PAGE = 400
      MAX_COUNT = MAX_PAGE * PER_PAGE

      def self.first(opts)
        all(opts).first
      end

      def self.all(opts)
        opts = opts.dup
        unless %w[All Blended Merchants].include? opts[:search_index]
          opts.reverse_merge!(:merchant_id => 'Amazon',
                              :condition => 'All')
        end
        opts[:availability] ||= 'Available' unless opts[:condition].nil? or opts[:condition] == 'New'
        opts[:item_page]    ||= (opts.delete('page') || 1)
        prep_responses(opts)

        response = Amazon::A2s.item_search(opts)

        # TODO: Max count is different for different indexes, for example, All only returns 5 pages
        max_count = [response.total_results, MAX_COUNT].min
        WillPaginate::Collection.create(response.page, PER_PAGE, max_count) do |pager|
          # TODO: Some of the returned items may not include offers, we may need something like this:
          #.reject {|i| i.offers[:totaloffers] == '0' }
          pager.replace response.items
        end
      end

    private
      SMALL_RESPONSE_GROUPS = %w{Small ItemAttributes Images}
      DEFAULT_RESPONSE_GROUPS = SMALL_RESPONSE_GROUPS + %w{Offers VariationSummary BrowseNodes}

      def self.prep_responses(opts)
        opts[:response_group] ||= []
        unless opts[:response_group].is_a? Array
          raise ArgumentError.new("Response groups are required to be in array form")
        end
        opts[:response_group] += DEFAULT_RESPONSE_GROUPS
      end
    end
  end
end