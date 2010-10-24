require_relative "./../test_helper"

module Amazon
  module Associates
    class CacheTest < Test::Unit::TestCase
      include FilesystemTestHelper
      context "caching get" do
        setup do
          set_valid_caching_options(CACHE_TEST_PATH)
        end

        teardown do
          reset_cache
        end

        should "optionally allow for a caching strategy in configuration" do
          assert_nothing_raised do
            set_valid_caching_options(CACHE_TEST_PATH)
          end
          assert Amazon::Associates.caching_enabled?
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
