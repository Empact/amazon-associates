module Amazon
  module Associates
    class SimilarityLookupResponse < SearchResponse
      xml_name 'SimilarityLookupResponse'

#      xml_reader :request_query, :as => SimilarityLookupRequest, :in => 'Items/Request', :required => true
    end
  end
end