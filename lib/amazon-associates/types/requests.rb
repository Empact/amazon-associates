module Amazon
  module Associates
    class Request
      include ROXML

      xml_reader :valid?, :from => 'IsValid'
      xml_reader :errors, [Error], :from => 'Error' do |errors|
        errors.collect do |error|
          if error.code && !IGNORE_ERRORS.include?(error.code)
            if exception = ERROR[error.code]
              exception.new("#{error.message} (#{@url})")
            else
              RuntimeError.new("#{error.code}: #{error.message} (#{@url})")
            end
          end
        end
      end

      def ==(other)
        (instance_variables.sort == other.instance_variables.sort) && instance_variables.all? do |v|
          instance_variable_get(v) == other.instance_variable_get(v)
        end
      end
    end

    class ItemSearchRequest < Request
      xml_reader :current_page, :from => 'ItemPage', :in => 'ItemSearchRequest',
                 :as => Integer, :else => 1
    end

    class ItemLookupRequest < Request
    end

    class BrowseNodeLookupRequest < Request
      xml_reader :response_groups, [:text], :from => 'ResponseGroup', :in => 'BrowseNodeLookupRequest'
    end

    class CartRequest < Request
    end
  end
end