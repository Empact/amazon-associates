module Amazon
  module Associates
    class ImageSet < ApiResult
      xml_reader :category, :attr, :required => true
      xml_reader :small, Image, :from => 'SmallImage'
      xml_reader :medium, Image, :from => 'MediumImage'
      xml_reader :large, Image, :from => 'LargeImage'
      xml_reader :swatch, Image, :from => 'SwatchImage'
    end
  end
end