module Amazon
  class A2s
    class BrowseNodeLookupResponse < Response
      xml_name 'BrowseNodeLookupResponse'
      xml_reader :browse_nodes, [BrowseNode], :from => 'BrowseNode', :in => 'BrowseNodes'
    end
  end
end