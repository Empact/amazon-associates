module Amazon
  class BrowseNode
    include ROXML

    xml_text :id, :from => :browsenodeid
    xml_text :name
    xml_object :parent, BrowseNode, :from => :browsenode, :in => :ancestors

    def initialize(id, name, parent)
      @id = id
      @name = name
      @parent = parent
    end

    def to_s
      "#{@name}#{' : ' + @parent.to_s if @parent}"
    end

    def inspect
      sprintf("#<%s:%s %s>", self.class.to_s, @id, self)
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
