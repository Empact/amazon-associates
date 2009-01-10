module Amazon
  module Associates
    class ListmaniaList < ApiResult
      xml_name 'ListmaniaList'
      xml_reader :id, :text => 'ListId'
      xml_reader :name, :text => 'ListName'
    end
  end
end