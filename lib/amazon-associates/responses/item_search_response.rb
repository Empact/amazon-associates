module Amazon
  module Associates
    class ItemSearchResponse < Response
      xml_name 'ItemSearchResponse'

      attr_accessor :url # TODO would be just a reader if we can figure out xml construction better
      xml_reader :operation_request, OperationRequest, :from => 'OperationRequest'
      xml_reader :items, [Item], :from => 'Item', :in => 'Items'
      xml_reader :total_results, :from => 'TotalResults', :in => 'Items', :as => Integer
      xml_reader :total_pages, :from => 'TotalPages', :in => 'Items', :as => Integer
      xml_reader :request, ItemSearchRequest, :from => 'Request', :in => 'Items'
    end
  end
end