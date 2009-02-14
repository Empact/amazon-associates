module Amazon
  module Associates
    class Image < ApiResult
      xml_reader :url, :from => 'URL'
      xml_reader :width, :as => Measurement
      xml_reader :height, :as => Measurement

      def initialize(url = nil, width = nil, height = nil)
        @url = url
        @width = to_measurement(width)
        @height = to_measurement(height)
      end

      def ==(other)
        return nil unless other.is_a? Image
        url == other.url and width == other.width and height == other.height
      end

      def size
        unless height.units == 'pixels' and width.units == 'pixels'
          raise 'size not available for images not denominated in pixels'
        end

        "#{width.value.round}x#{height.value.round}"
      end

      def inspect
        "#<#{self.class}: #{url},#{width}x#{height}>"
      end

    private
      def to_measurement(arg)
        arg && (arg.is_a?(Measurement) ? arg : Measurement.new(arg, 'pixels'))
      end
    end
  end
end
