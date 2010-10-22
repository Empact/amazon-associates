module Amazon
  module Associates
    class Ordinal < ApiResult
      include Comparable

      xml_reader :value, :from => :content do |val|
        val.to_i
      end

      def initialize(value = nil)
        @value = value && value.to_i
      end

      def to_s
        @value.ordinalize
      end
      alias :inspect :to_s

      def ==(other)
        @value == other
      end
    end
  end
end
