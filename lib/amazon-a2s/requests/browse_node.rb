require File.join(File.dirname(__FILE__), '../request')

module Amazon
  class A2s
		request :browse_node_lookup => :browse_node_id do |opts|
		  opts[:response_group] ||= 'TopSellers'
		end
  end
end