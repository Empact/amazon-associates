module Amazon
  module Associates
    class Response
      include ROXML

      attr_reader :url
      delegate :current_page, :to => :request

      def xml_initialize(url)
        @url = url
        # these can't be done as blocks because we need @url available
        @errors = process_errors(errors)
        raise errors.first unless errors.empty?
      end

      def ==(other)
        (instance_variables.sort == other.instance_variables.sort) && instance_variables.all? do |v|
          instance_variable_get(v) == other.instance_variable_get(v)
        end
      end

    private
      def process_errors(vals)
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
  end
end