require File.join(File.dirname(__FILE__), 'amazon-a2s', 'extensions', 'pp')
require File.join(File.dirname(__FILE__), 'amazon-a2s', 'request')

module Amazon
  class A2s
    # Default search options 
    @options = {}
    @debug = false

    # see http://railstips.org/2006/11/18/class-and-instance-variables-in-ruby
    class << self;
      attr_accessor :debug, :options;
    
      def options
        if access_key = @options.delete(:aws_access_key_id)
          @options[:aWS_access_key_id] = access_key
        end
        @options
      end
    end

  protected
    def self.log(s)
      return unless debug
      if defined? RAILS_DEFAULT_LOGGER
        RAILS_DEFAULT_LOGGER.error(s)
      elsif defined? LOGGER
        LOGGER.error(s)
      else
        puts s
      end
    end
  end
end