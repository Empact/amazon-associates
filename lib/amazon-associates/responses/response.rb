module Amazon
  module Associates
    class Response
      include ROXML

      attr_reader :url
      delegate :current_page, :to => :request
      xml_reader :request_valid?, :from => 'IsValid', :in => 'Items/Request'

      xml_reader :item_errors, [Error], :from => 'Error', :in => "Items/Request/Errors"
      xml_reader :cart_errors, [Error], :from => 'Error', :in => "Cart/Request/Errors"

      def errors
        item_errors + cart_errors
      end

      def xml_initialize(url)
        @url = url
        # these can't be done as blocks because we need @url available
        @cart_errors = process_errors(cart_errors)
        @item_errors = process_errors(item_errors)
        raise errors.first unless errors.empty?
      end

      def ==(other)
        instance_variables == other.instance_variables && instance_variables.all? do |v|
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