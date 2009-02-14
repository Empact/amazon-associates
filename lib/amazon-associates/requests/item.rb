require File.join(File.dirname(__FILE__), '../request')

module Amazon
  module Associates
    request :item_search => :keywords do |opts|
      # TODO: Default to blended?  Don't show others except on refined search page?
      opts[:search_index] ||= 'Books'
      opts
    end
    request :similarity_lookup => :item_id,
            :item_lookup => :item_id
  end
end