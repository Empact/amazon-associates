require File.join(File.dirname(__FILE__), '../request')

module Amazon
  module Associates
		request :browse_node_lookup => :browse_node_id do |opts|
		  opts[:response_group] ||= 'TopSellers'
		  opts
		end
  end
end