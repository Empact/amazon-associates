module Amazon
  module Associates
    class OperationRequest < ApiResult
      xml_reader :request_id
      xml_reader :arguments, :as => {:attrs => ['Name', 'Value']}
      xml_reader :request_processing_time
    end
  end
end