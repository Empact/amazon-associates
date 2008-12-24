module Amazon
  module Associates
    class ItemLookupResponse < Response
      xml_name 'ItemLookupResponse'
      xml_reader :items, [Item], :from => 'Item', :in => 'Items'
      xml_reader :current_page, :from => 'ItemPage', :as => Integer, :else => 1

      def item
        items.only
      end
    end
  end
end