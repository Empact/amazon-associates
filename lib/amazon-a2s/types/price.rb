module Amazon
  class Price
    include Comparable
    attr_reader :cents, :currency
    
    def initialize(str, cents = nil, currency = nil)
      @str = str.to_s
      @cents = cents.to_i if cents
      @currency = currency.to_s if currency
    end
    
    def <=>(other)
      return nil if @currency.nil? or @cents.nil?
      return nil if @currency != other.currency
      
      @cents <=> other.cents
    end
    
    def to_s
      @str
    end
    alias_attribute :inspect, :to_s
  end
end
