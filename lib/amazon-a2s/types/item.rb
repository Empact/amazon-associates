module Amazon
  class Item
    include ROXML

    xml_name 'Item'
    xml_reader :asin, :from => 'ASIN'
    xml_reader :detail_page_url, :from => 'DetailPageUrl'
    xml_reader :attributes, {:key => :name,
                             :value => :content}, :from => 'ItemAttributes'
    xml_reader :small_image, Image, :from => 'SmallImage'
    xml_reader :listmania_lists, [ListmaniaList], :from => 'ListmaniaLists'
    xml_reader :authors, [:text]
    xml_reader :edition, :as => Integer
    xml_reader :browse_nodes, [BrowseNode], :from => 'BrowseNode', :in => 'BrowseNodes'

    def ==(other)
      asin == other.asin
    end

    def eql?(other)
      asin == other.asin
    end
  end
end