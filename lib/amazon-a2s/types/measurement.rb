module Amazon
  class A2s
    class Measurement
      include ROXML
      include Comparable

      xml_reader :value, :content
      xml_reader :units, :attr => 'Units'

      def xml_initialize
        initialize(value, units)
      end

      def initialize(value, units = 'pixels')
        @value = Float(value)
        @units = units.to_s

        if @units.starts_with? 'hundredths-'
          @value /= 100.0
          @units = @units.split('hundredths-')[1]
        end
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
    end
  end
end
