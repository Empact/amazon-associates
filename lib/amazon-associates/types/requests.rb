module Amazon
  module Associates
    class Request < ApiResult
      xml_reader :valid?, :from => 'IsValid', :required => true
      xml_reader :errors, :as => [Error] do |errors|
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

    class ItemSearchRequest < ApiResult
      xml_name 'ItemSearchRequest'

      xml_reader :current_page, :from => 'ItemPage', :as => Integer, :else => 1
    end

    class ItemLookupRequest < ApiResult
    end

    class BrowseNodeLookupRequest < ApiResult
      xml_name 'BrowseNodeLookupRequest'

      xml_reader :response_groups, :as => []
    end

    class CartRequest < ApiResult
    end

    class OperationRequest < ApiResult
      xml_name 'OperationRequest'

      xml_reader :request_id
      xml_reader :arguments, :as => {:key => '@Name', :value => '@Value'}
      xml_reader :request_processing_time
    end
  end
end