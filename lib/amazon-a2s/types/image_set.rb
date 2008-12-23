module Amazon
  class A2s
    class ImageSet
      include ROXML

      xml_reader :category, :attr => 'Category'
      xml_reader :small, Image, :from => 'SmallImage'
      xml_reader :medium, Image, :from => 'MediumImage'
      xml_reader :large, Image, :from => 'LargeImage'
      xml_reader :swatch, Image, :from => 'SwatchImage'
    end
  end
end