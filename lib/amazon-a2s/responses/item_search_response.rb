require 'roxml'

module Amazon
  class A2s
    class ItemSearchResponse
      include ROXML

      xml_name :itemsearchresponse

      attr_accessor :url # TODO would be just a reader if we can figure out xml construction better
      xml_reader :operation_request, OperationRequest, :from => 'OperationRequest'
      xml_reader :items, [Item], :from => 'Item', :in => 'Items'
      xml_reader :request, Request, :from => 'Request', :in => 'Items'
      xml_reader :total_results, :from => 'TotalResults', :in => 'Items', :as => Integer
      xml_reader :page, :from => 'ItemPage', :as => Integer
      xml_reader :total_pages, :from => 'TotalPages', :in => 'Items', :as => Integer
    end
  end
end