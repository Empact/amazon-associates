module Amazon
  module Associates
    class Error
      include ROXML

      xml_reader :code, :from => 'Code'
      xml_reader :message, :from => 'Message'
    end
  end
end