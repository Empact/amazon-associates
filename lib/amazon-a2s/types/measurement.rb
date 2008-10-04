module Amazon
  class Measurement
    include ROXML
    include Comparable
    attr_reader :value, :units

    xml_reader :value, :content
    xml_reader :units, :attr
    xml_construct :value, :units

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
