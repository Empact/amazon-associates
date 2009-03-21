module Amazon
  module Associates
    class SimilarityLookupResponse < Response
      xml_name 'SimilarityLookupResponse'

      attr_accessor :url # TODO would be just a reader if we can figure out xml construction better
      xml_reader :operation_request, :as => OperationRequest
      xml_reader :items, :as => [Item], :required => true
      xml_reader :total_results, :in => 'Items', :as => Integer
      xml_reader :total_pages, :in => 'Items', :as => Integer
      xml_reader :request, :as => ItemSearchRequest, :in => 'Items', :required => true
    end
  end
end