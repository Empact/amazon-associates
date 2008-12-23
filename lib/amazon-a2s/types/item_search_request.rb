module Amazon
  class A2s
    class ItemSearchRequest
      include ROXML

      xml_reader :current_page, :from => 'ItemPage', :as => Integer, :else => 1
    end
  end
end