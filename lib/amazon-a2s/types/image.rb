require 'roxml'
require File.join(File.dirname(__FILE__), 'measurement')

module Amazon
  class Image
    include ROXML

    xml_text :url, :as => :readonly
    xml_object :width, Measurement, :as => :readonly
    xml_object :height, Measurement, :as => :readonly

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
