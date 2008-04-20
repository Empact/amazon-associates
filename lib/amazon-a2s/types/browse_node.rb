module Amazon
  class BrowseNode
    attr_reader :id, :name, :ancestors
    
    def initialize(id, name, ancestors)
      @id = id
      @name = name
      @ancestors = ancestors
    end
    
    def to_s
      "#{@name}#{' : ' + @ancestors.to_s if @ancestors}"
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
                
        ancestor = instance_variable_get :@ancestors
	      while ancestor
	        return true if markers.include? ancestor.name
	        ancestor = ancestor.ancestors
	      end
        false
      end
    end
  end
end
