module Amazon
  class ListmaniaList
    include ROXML

    xml_name 'ListmaniaList'
    xml_reader :id, :text => 'ListId'
    xml_reader :name, :text => 'ListName'
  end
end