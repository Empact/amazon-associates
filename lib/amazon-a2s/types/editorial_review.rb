module Amazon
  class EditorialReview
    include ROXML

    xml_reader :source, :from => 'Source'
    xml_reader :content, :from => 'Content'
  end
end