require File.dirname(__FILE__) + "/../test_helper"

module Amazon
  module Associates
    class CacheTest < Test::Unit::TestCase
      include FilesystemTestHelper
      context "caching get" do
        setup do
          get_cache_directory
          get_valid_caching_options
        end

        teardown do
          destroy_cache_directory
          destroy_caching_options
        end

        should "optionally allow for a caching strategy in configuration" do
          assert_nothing_raised do
            Amazon::Associates.configure do |options|
              options[:caching_strategy] = :filesystem
              options[:caching_options] = VALID_CACHING_OPTIONS
            end
          end
          raise Amazon::Associates.options.inspect unless Amazon::Associates.caching_enabled?
        end

        should "raise an exception if a caching strategy is specified that is not found" do
          assert_raise Amazon::Associates::ConfigurationError do
            Amazon::Associates.configure do |options|
              options[:caching_strategy] = "foo"
            end
          end
        end
      end
    end
  end
end
