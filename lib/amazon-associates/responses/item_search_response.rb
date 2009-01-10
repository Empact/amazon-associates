module Amazon
  module Associates
    class ItemSearchResponse < Response
      xml_name 'ItemSearchResponse'

      attr_accessor :url # TODO would be just a reader if we can figure out xml construction better
      xml_reader :operation_request, OperationRequest
      xml_reader :items, [Item]
      xml_reader :total_results, :in => 'Items', :as => Integer
      xml_reader :total_pages, :in => 'Items', :as => Integer
      xml_reader :request, ItemSearchRequest, :in => 'Items'
    end
  end
end