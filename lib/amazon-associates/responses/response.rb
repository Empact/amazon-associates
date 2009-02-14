module Amazon
  module Associates
    class Response < ApiResult
      attr_reader :url
      delegate :current_page, :errors, :to => :request

      def initialize(url)
        @url = url
      end

      def ==(other)
        (instance_variables.sort == other.instance_variables.sort) && instance_variables.all? do |v|
          instance_variable_get(v) == other.instance_variable_get(v)
        end
      end

    private
      def after_parse
        # these can't be done as blocks because we need @url available
        raise errors.first unless errors.empty?
      end
    end
  end
end