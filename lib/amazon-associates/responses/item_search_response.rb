module Amazon
  module Associates
    class SearchResponse < Response
      attr_accessor :url # TODO would be just a reader if we can figure out xml construction better
      xml_reader :operation_request, :as => OperationRequest, :required => true
      xml_reader :request, :as => Request, :in => 'xmlns:Items'
      delegate :current_page, :to => :request_query

      xml_reader :items, :as => [Item]
      xml_reader :total_results, :in => 'xmlns:Items', :as => Integer
      xml_reader :total_pages, :in => 'xmlns:Items', :as => Integer
    end

    class ItemSearchResponse < SearchResponse
      xml_name 'ItemSearchResponse'

      xml_reader :request_query, :as => ItemSearchRequest, :in => 'xmlns:Items/xmlns:Request', :required => true
    end
  end
end