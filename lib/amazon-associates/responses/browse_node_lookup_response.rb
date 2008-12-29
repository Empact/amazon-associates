module Amazon
  module Associates
    class BrowseNodeLookupResponse < Response
      xml_name 'BrowseNodeLookupResponse'
      xml_reader :browse_nodes, [BrowseNode], :from => 'BrowseNode', :in => 'BrowseNodes'
      xml_reader :request, BrowseNodeLookupRequest, :from => 'Request', :in => 'BrowseNodes'
    end
  end
end