require File.join(File.dirname(__FILE__), '../request')

module Amazon
  class A2s
		request :item_search => :keywords do |opts|
		  opts[:search_index] ||= default_search_index
		end
		request :similarity_lookup => :item_id,
		        :item_lookup => :item_id
  end
end