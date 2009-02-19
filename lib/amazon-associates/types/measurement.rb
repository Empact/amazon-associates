module Amazon
  module Associates
    class Measurement < ApiResult
      include Comparable

      xml_reader :value, :from => :content, :as => Float
      xml_reader :units, :from => :attr

      def initialize(value = nil, units = 'pixels')
        @value = value && Float(value)
        @units = units.to_s
        normalize_hundredths
      end

      def to_s
        value = @value.whole? ? @value.to_i : @value
        #singularize here to avoid comparison problems
        units = @value == 1 ? @units.singularize : @units
        [value, units].join(' ')
      end
      alias_attribute :inspect, :to_s

      def to_i
        @value.round
      end

      def <=>(other)
        return nil unless @units == other.units

        @value <=> other.value
      end

    private
      def after_parse
        @units ||= 'pixels'
        normalize_hundredths
      end

      def normalize_hundredths
        if @units.try(:starts_with?, 'hundredths-')
          @value /= 100.0
          @units = @units.split('hundredths-')[1]
        end
      end
    end
  end
end
