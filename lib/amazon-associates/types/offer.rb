module Amazon
  module Associates
    class Offer
      include ROXML

      xml_reader :listing_id, :from => 'OfferListingId'
      xml_reader :price, Price, :from => 'Price'
      xml_reader :availability, :from => 'Availability'
      xml_reader :is_eligible_for_super_saver_shipping?, :from => 'IsEligibleForSuperSaverShipping', :in => 'OfferListing'
    end
  end
end