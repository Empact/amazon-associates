module Amazon
  module Associates
    class Response < ApiResult
      attr_reader :url
      delegate :current_page, :errors, :to => :request

      def xml_initialize(url)
        @url = url
        # these can't be done as blocks because we need @url available
        raise errors.first unless errors.empty?
      end

      def ==(other)
        (instance_variables.sort == other.instance_variables.sort) && instance_variables.all? do |v|
          instance_variable_get(v) == other.instance_variable_get(v)
        end
      end
    end
  end
end