module Amazon
  module Associates
    class Request
      include ROXML

      xml_reader :valid?, :from => 'IsValid'
    end

    class ItemSearchRequest < Request
      xml_reader :current_page, :from => 'ItemPage', :in => 'ItemSearchRequest',
                 :as => Integer, :else => 1
    end

    class ItemLookupRequest < Request
    end

    class BrowseNodeLookupRequest < Request
    end

    class CartRequest < Request
    end
  end
end