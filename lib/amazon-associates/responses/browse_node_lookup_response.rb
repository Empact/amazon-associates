module Amazon
  module Associates
    class BrowseNodeLookupResponse < Response
      xml_name 'BrowseNodeLookupResponse'
      xml_reader :browse_nodes, [BrowseNode]
      xml_reader :request, BrowseNodeLookupRequest, :in => 'BrowseNodes'
    end
  end
end