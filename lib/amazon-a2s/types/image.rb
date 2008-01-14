module Amazon
  class Image
    attr_reader :url, :width, :height
    
    def initialize(url, width, height)
      @url = url
      width = Measurement.new(width, 'pixels') unless width.is_a? Measurement
      @width = width
      height = Measurement.new(height, 'pixels') unless height.is_a? Measurement
      @height = height
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
  end
end