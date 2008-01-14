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
      @id == other.id and @name == other.name
    end
    
    %w{brand type}.each do |name|
      define_method("#{name}?") do
        ancestor = instance_variable_get :@ancestors
	      while ancestor
	        return true if ancestor.name == name.titleize
	        ancestor = ancestor.ancestors
	      end
        false
      end
    end
  end
end