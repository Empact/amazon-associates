module Amazon
  class Request
    include ROXML

    xml_reader :valid, :text => 'IsValid' do |val|
      val == "True"
    end

    def valid?
      valid
    end
  end
end