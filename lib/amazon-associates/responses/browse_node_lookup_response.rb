module Amazon
  module Associates
    class BrowseNodeLookupResponse < Response
      xml_name 'BrowseNodeLookupResponse'
      xml_reader :browse_nodes, :as => [BrowseNode]
      xml_reader :request, :as => BrowseNodeLookupRequest, :in => 'BrowseNodes'
    end
  end
end