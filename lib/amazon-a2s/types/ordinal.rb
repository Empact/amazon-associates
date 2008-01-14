module Amazon
  class Ordinal
    attr_reader :value

    def initialize(value)
      @value = value.to_i
    end

    def to_s
      @value.ordinalize
    end
    alias_attribute :inspect, :to_s
    
    def ==(other)
      @value == other
    end
  end
end