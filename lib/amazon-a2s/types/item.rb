module Amazon
  class Item
    include ROXML

    xml_name 'Item'
    xml_reader :asin, :from => 'ASIN'
    xml_reader :detail_page_url, :from => 'DetailPageUrl'
    xml_reader :list_price, Price, :from => 'ListPrice', :in => 'ItemAttributes'
    xml_reader :attributes, {:key => :name,
                             :value => :content}, :in => 'ItemAttributes'
    xml_reader :small_image, Image, :from => 'SmallImage'
    #TODO: would be nice to have :key => '@category' and :value => {[Image] => 'SwatchImage'}
    xml_reader :image_sets, [ImageSet], :from => 'ImageSet', :in => 'ImageSets'
    xml_reader :listmania_lists, [ListmaniaList], :from => 'ListmaniaList', :in => 'ListmaniaLists'
    xml_reader :browse_nodes, [BrowseNode], :from => 'BrowseNode', :in => 'BrowseNodes'
    xml_reader :offers, [Offer], :from => 'Offer', :in => 'Offers'
    # TODO: This should be offers.total_new
    xml_reader :total_new_offers, :from => 'TotalNew', :in => 'OfferSummary', :as => Integer
    # TODO: This should be offers.total
    xml_reader :total_offers, :from => 'TotalOffers', :in => 'Offers', :as => Integer

    xml_reader :creators, {:key => {:attr => 'Role'}, :value => :content}, :from => 'Creator', :in => 'ItemAttributes'
    xml_reader :authors, [:text], :from => 'Author', :in => 'ItemAttributes'
    xml_reader :edition, Ordinal, :from => 'Edition', :in => 'ItemAttributes'
    xml_reader :batteries_included?, :from => 'BatteriesIncluded', :in => 'ItemAttributes'
    xml_reader :lowest_new_price, Price, :from => 'LowestNewPrice', :in => 'OfferSummary'

    xml_reader :editorial_reviews, [EditorialReview], :from => 'EditorialReview', :in => 'EditorialReviews'
    xml_reader :customer_reviews, [CustomerReview], :in => 'CustomerReviews'

    def ==(other)
      asin == other.asin
    end

    def eql?(other)
      asin == other.asin
    end

    def author
      authors.only
    end
  end
end