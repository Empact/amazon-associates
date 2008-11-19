require 'roxml'

module Amazon
  class A2s
    class BrowseNodeLookupResponse
      include ROXML

      xml_name :browsenodelookupresponse
      xml_reader :browse_nodes, [BrowseNode], :from => 'BrowseNode', :in => 'BrowseNodes'
    end
  end
end