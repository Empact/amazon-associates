module Amazon
  module Associates
    class Error < ApiResult
      xml_reader :code
      xml_reader :message
    end
  end
end