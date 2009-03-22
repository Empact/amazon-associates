module Amazon
  module Associates
    class ItemSearchResponse < Response
      xml_name 'ItemSearchResponse'

      attr_accessor :url # TODO would be just a reader if we can figure out xml construction better
      xml_reader :request, :as => OperationRequest, :required => true
      xml_reader :search_request, :as => ItemSearchRequest, :from => 'Request', :in => 'Items'

      xml_reader :items, :as => [Item]
      xml_reader :total_results, :in => 'Items', :as => Integer
      xml_reader :total_pages, :in => 'Items', :as => Integer

      def current_page
        search_request.current_page
      end
    end
  end
end