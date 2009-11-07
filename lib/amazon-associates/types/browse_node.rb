module Amazon
  module Associates
    class Item < ApiResult
      # forward-declaration...
    end

    class BrowseNode < ApiResult
      xml_reader :id, :from => 'xmlns:BrowseNodeId', :required => true
      xml_reader :name, :from => 'Name'
      xml_reader :parent, :as => BrowseNode, :from => 'xmlns:BrowseNode', :in => 'xmlns:Ancestors'
      xml_reader :children, :as => [BrowseNode]
      xml_reader :top_sellers, :as => [Item]

      def initialize(id = nil, name = nil, parent = nil)
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
