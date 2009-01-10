module Amazon
  module Associates
    class ItemLookupResponse < Response
      xml_name 'ItemLookupResponse'
      xml_reader :items, [Item]
      xml_reader :current_page, :from => 'ItemPage', :as => Integer, :else => 1
      xml_reader :request, ItemLookupRequest, :in => 'Items'

      def item
        items.only
      end
    end
  end
end