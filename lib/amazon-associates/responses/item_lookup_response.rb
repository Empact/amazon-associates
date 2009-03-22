module Amazon
  module Associates
    class ItemLookupResponse < Response
      xml_name 'ItemLookupResponse'
      xml_reader :items, :as => [Item]
      xml_reader :current_page, :from => 'ItemPage', :as => Integer, :else => 1
      xml_reader :request, :as => Request, :in => 'Items', :required => true
      xml_reader :request_query, :as => ItemLookupRequest, :from => 'SimilarityLookupRequest', :in => 'Items/Request'

      def item
        raise IndexError, "more than one item" if items.size > 1
        items.first
      end
    end
  end
end