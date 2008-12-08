module Amazon
  class A2s
    class ItemLookupResponse < Response
      xml_name 'ItemLookupResponse'
      xml_reader :items, [Item], :from => 'Item', :in => 'Items'

      def item
        items.only
      end
    end
  end
end