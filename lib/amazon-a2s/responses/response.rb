module Amazon
  class A2s
    class Response
      include ROXML

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

    private
      def process_errors(vals)
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
    end
  end
end