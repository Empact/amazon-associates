module Amazon
  class Image
    attr_reader :url, :width, :height

    def initialize(url, width, height)
      @url = url
      @width = to_measurement(width)
      @height = to_measurement(height)
    end

    def ==(other)
      return nil unless other.is_a? Image
      @url == other.url and @width == other.width and @height == other.height
    end

    def size
      unless height.units == 'pixels' and width.units == 'pixels'
        raise 'size not available for images not denominated in pixels'
      end

      "#{width.value.round}x#{height.value.round}"
    end

    def inspect
      sprintf("#<%s: %s,%sx%s>", self.class.to_s, self.url, self.width, self.height)
    end

  private
    def to_measurement(arg)
      arg.is_a?(Measurement) ? arg : Measurement.new(arg, 'pixels')
    end
  end
end
