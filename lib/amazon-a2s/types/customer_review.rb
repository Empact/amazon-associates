module Amazon
  class CustomerReview
    include ROXML

    xml_name 'Review'
    xml_reader :asin, :from => 'ASIN'
    xml_reader :rating, :from => 'Rating', :as => Integer
    xml_reader :helpful_votes, :from => 'HelpfulVotes', :as => Integer
    xml_reader :total_votes, :from => 'TotalVotes', :as => Integer
    xml_reader :summary, :from => 'Summary'
    xml_reader :content, :from => 'Content'
    xml_reader :customer_id, :from => 'CustomerId'
    xml_reader :date, :from => 'Date', :as => Date
  end
end