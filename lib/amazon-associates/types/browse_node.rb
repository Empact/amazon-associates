module Amazon
  module Associates
    class Item < ApiResult
      # forward-declaration...
    end

    class BrowseNode < ApiResult
      xml_reader :id, :text => 'BrowseNodeId'
      xml_reader :name, :from => 'Name'
      xml_reader :parent, BrowseNode, :from => 'BrowseNode', :in => 'Ancestors'
      xml_reader :children, [BrowseNode]
      xml_reader :top_sellers, [Item]

      def initialize(id, name, parent)
        @id = id
        @name = name
        @parent = parent
      end

      def to_s
        "#{@name}#{' : ' + @parent.to_s if @parent}"
      end

      def inspect
        "#<#{self.class}:#{@id} #{self}>"
      end

      def ==(other)
        return false unless other.respond_to?(:name, :id)
        @name == other.name and @id == other.id
      end

      {:brand => [:manufacturers, :custom_brands], :type => [:categories]}.each_pair do |name, aliases|
        define_method("#{name}?") do
          markers = ([name] + aliases).map {|n| n.to_s.titleize}
          return true if markers.include? instance_variable_get(:@name)

          parent = instance_variable_get :@parent
          while parent
            return true if markers.include? parent.name
            parent = parent.parent
          end
          false
        end
      end
    end
  end
end
