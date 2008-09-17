module Amazon
  class Ordinal
    include Comparable
    include ROXML
    xml_reader :value, :text_content do |val|
      val.to_i
    end

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
