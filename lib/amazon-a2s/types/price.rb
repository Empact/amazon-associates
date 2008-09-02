module Amazon
  class Price
    include ROXML
    include Comparable
    attr_reader :cents, :currency

    xml_reader :to_s, :from => :formattedprice
    xml_reader :currency, :from => :currencycode
    xml_reader :cents, :from => :amount do |val|
      Integer(val)
    end

    def initialize(str, cents = nil, currency = nil)
      @to_s = str.to_s
      @cents = Integer(cents)
      @currency = currency.to_s
    end

    def <=>(other)
      return nil if @currency.nil? or @cents.nil?
      return nil if @currency != other.currency

      @cents <=> other.cents
    end

    def inspect
      "#{to_s} #{currency}"
    end
  end
end
