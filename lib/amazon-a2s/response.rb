%w{ errors extensions/core types/operation_request
   types/error types/customer_review types/editorial_review types/ordinal types/listmania_list types/browse_node types/measurement types/image types/image_set types/price types/offer types/item types/request types/cart
   responses/response responses/item_search_response responses/browse_node_lookup_response }.each do |file|
  require File.join(File.dirname(__FILE__), file)
end
