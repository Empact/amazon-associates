module Amazon
  module Associates
    class EditorialReview < ApiResult
      xml_reader :source
      xml_reader :content
    end
  end
end