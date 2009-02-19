module Amazon
  module Associates
    class ListmaniaList < ApiResult
      xml_name 'ListmaniaList'
      xml_reader :id, :from => 'ListId'
      xml_reader :name, :from => 'ListName'
    end
  end
end