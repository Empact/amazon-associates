require File.join(File.dirname(__FILE__), '../request')

module Amazon
  module Associates
    request :item_search => :keywords do |opts|
      opts[:search_index] ||= default_search_index
      opts
    end
    request :similarity_lookup => :item_id,
            :item_lookup => :item_id
  end
end