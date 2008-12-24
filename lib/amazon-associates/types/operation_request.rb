module Amazon
  class OperationRequest
    include ROXML

    xml_reader :request_id, :from => :requestid
    xml_reader :arguments, {:attrs => ['Name', 'Value']}, :from => 'Argument', :in => 'Arguments'
    xml_reader :request_processing_time, :from => :requestprocessingtime
  end
end