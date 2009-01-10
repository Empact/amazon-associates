module Amazon
  module Associates
    class CustomerReview < ApiResult
      xml_name 'Review'
      xml_reader :asin, :from => 'ASIN'
      xml_reader :rating, :as => Integer
      xml_reader :helpful_votes, :as => Integer
      xml_reader :total_votes, :as => Integer
      xml_reader :summary
      xml_reader :content
      xml_reader :customer_id
      xml_reader :date, :as => Date
    end
  end
end