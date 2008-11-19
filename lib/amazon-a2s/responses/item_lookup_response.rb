require 'roxml'

module Amazon
  class A2s
    class ItemLookupResponse
      include ROXML

      xml_name :itemlookupresponse
      xml_reader :items, [Item], :from => 'Item', :in => 'Items'
    end
  end
end