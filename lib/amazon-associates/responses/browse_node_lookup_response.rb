module Amazon
  module Associates
    class BrowseNodeLookupResponse < Response
      xml_name 'BrowseNodeLookupResponse'
      xml_reader :browse_nodes, :as => [BrowseNode]
      xml_reader :request, :as => Request, :in => 'BrowseNodes'
      xml_reader :request_query, :as => BrowseNodeLookupRequest, :in => 'BrowseNodes/Request'
    end
  end
end