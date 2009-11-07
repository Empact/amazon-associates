module Amazon
  module Associates
    class BrowseNodeLookupResponse < Response
      xml_name 'BrowseNodeLookupResponse'
      xml_reader :browse_nodes, :as => [BrowseNode]
      xml_reader :request, :as => Request, :in => 'xmlns:BrowseNodes'
      xml_reader :request_query, :as => BrowseNodeLookupRequest, :in => 'xmlns:BrowseNodes/xmlns:Request'
    end
  end
end