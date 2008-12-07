module Amazon
  class A2s
    class Response
      include ROXML

      xml_reader :errors, [Error], :from => 'Error', :in => "Items/Request/Errors" do |vals|
        if vals.blank?
          []
        else
          vals.collect do |error|
            if error.code && !IGNORE_ERRORS.include?(error.code)
              if exception = ERROR[error.code]
                exception.new("#{error.message} (#{@url})")
              else
                RuntimeError.new("#{error.code}: #{error.message} (#{@url})")
              end
            end
          end
        end
      end

      def xml_initialize(url)
        @url = url
        raise errors.first unless errors.empty?
      end
    end
  end
end