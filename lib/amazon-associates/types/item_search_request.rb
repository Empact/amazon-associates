module Amazon
  module Associates
    class ItemSearchRequest < ApiResult
      xml_reader :current_page, :from => 'ItemPage', :as => Integer, :else => 1
    end
  end
end