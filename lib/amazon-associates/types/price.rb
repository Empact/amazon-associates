module Amazon
  module Associates
    class Price < ApiResult
      include Comparable
      attr_reader :cents, :currency

      xml_reader :to_s, :from => 'FormattedPrice'
      xml_reader :currency, :from => 'CurrencyCode'
      xml_reader :cents, :from => 'Amount', :as => Integer

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
end
