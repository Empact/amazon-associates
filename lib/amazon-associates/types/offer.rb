module Amazon
  module Associates
    class Offer < ApiResult
      xml_reader :listing_id, :from => 'OfferListingId'
      xml_reader :price, Price
      xml_reader :availability
      xml_reader :is_eligible_for_super_saver_shipping?, :in => 'OfferListing'
    end
  end
end