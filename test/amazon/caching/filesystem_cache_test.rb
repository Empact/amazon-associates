require File.dirname(__FILE__) + "/../../test_helper"

class Amazon::Associates::FilesystemCacheTest < Test::Unit::TestCase
  include FilesystemTestHelper
  context "setting up filesystem caching" do
    teardown do
      Amazon::Associates.configure do |options|
        options[:caching_strategy] = nil
        options[:caching_options] = nil
      end
    end
    
    should "require a caching options hash with a cache_path key" do
      assert_raise Amazon::Associates::ConfigurationError do
        Amazon::Associates.configure do |options|
          options[:caching_strategy] = :filesystem
          options[:caching_options] = nil
        end
      end
    end
    
    should "raise an exception when a cache_path is specified that doesn't exist" do
      assert_raise Amazon::Associates::ConfigurationError do
        Amazon::Associates.configure do |options|
          options[:caching_strategy] = :filesystem
          options[:caching_options] = {:cache_path => "foo123"}
        end
      end
    end
    
    should "set default values for disk_quota and sweep_frequency" do
      Amazon::Associates.configure do |options|
        options[:caching_strategy] = :filesystem
        options[:caching_options] = {:cache_path => "."}
      end
      
      assert_equal Amazon::Associates::FilesystemCache.disk_quota, Amazon::Associates::FilesystemCache.disk_quota
      assert_equal Amazon::Associates::FilesystemCache.sweep_frequency, Amazon::Associates::FilesystemCache.sweep_frequency
    end
    
    should "override the default value for disk quota if I specify one" do
      quota = 400
      Amazon::Associates.configure do |options|
        options[:caching_strategy] = :filesystem
        options[:caching_options] = {:cache_path => ".", :disk_quota => quota}
      end
      
      assert_equal quota, Amazon::Associates::FilesystemCache.disk_quota
    end
    
    should "override the default value for cache_frequency if I specify one" do
      frequency = 4
      Amazon::Associates.configure do |options|
        options[:caching_strategy] = :filesystem
        options[:caching_options] = {:cache_path => ".", :sweep_frequency => frequency}
      end
      
      assert_equal frequency, Amazon::Associates::FilesystemCache.sweep_frequency
    end
  end
  
  context "caching a request" do
    
    setup do
      get_cache_directory
      get_valid_caching_options
      @resp = Amazon::Associates.item_lookup("0974514055")
      @filename = Digest::SHA1.hexdigest(@resp.url)
    end
    
    teardown do
      destroy_cache_directory
      destroy_caching_options
    end
    
    should "create a folder in the cache path with the first three letters of the digested filename" do
      assert FileTest.exists?(File.join(CACHE_PATH, @filename[0..2]))
    end
    
    should "create a file in the cache path with a digested version of the url " do
      assert FileTest.exists?(File.join(CACHE_PATH, @filename[0..2], @filename))
    end
    
    should "create a file in the cache path with the response inside it" do
      open(File.join(CACHE_PATH + @filename[0..2], @filename)) do |f|
        assert_equal @resp, Marshal.load(f)
      end
    end
  end
  
  context "getting a cached request" do
    setup do
      get_cache_directory
      get_valid_caching_options
      do_request
    end
    
    teardown do
      destroy_cache_directory
      destroy_caching_options
    end
    
    should "not do an http request the second time the lookup is performed due a cached copy" do
      Net::HTTP.expects(:get_response).never
      do_request
    end
    
    should "return the same response as the original request" do
      original = @resp
      do_request
      assert_equal(original, @resp)
    end

    should "not include cache parameters in the response" do
      assert_no_match(/CachingOptions/, @resp.url)
      assert_no_match(/caching_options/, @resp.url)
      assert_no_match(/cache_path/, @resp.url)
      assert_no_match(/disk_quota/, @resp.url)
    end
  end
  
  context "sweeping cached requests" do
    setup do
      get_cache_directory
      get_valid_caching_options
      do_request
    end
    
    teardown do
      destroy_cache_directory
      destroy_caching_options
    end
    
    should "not perform the sweep if the timestamp is within the range of the sweep frequency and quota is not exceeded" do
      Amazon::Associates::FilesystemCache.expects(:sweep_time_expired?).returns(false)
      Amazon::Associates::FilesystemCache.expects(:disk_quota_exceeded?).returns(false)
      
      Amazon::Associates::FilesystemCache.expects(:perform_sweep).never
      
      do_request
    end
    
    should "perform a sweep if the quota is exceeded" do
      Amazon::Associates::FilesystemCache.stubs(:sweep_time_expired?).returns(false)
      Amazon::Associates::FilesystemCache.expects(:disk_quota_exceeded?).once.returns(true)
      
      Amazon::Associates::FilesystemCache.expects(:perform_sweep).once
      
      do_request
    end
    
    should "perform a sweep if the sweep time is expired" do
      Amazon::Associates::FilesystemCache.expects(:sweep_time_expired?).once.returns(true)
      Amazon::Associates::FilesystemCache.stubs(:disk_quota_exceeded?).returns(false)
      Amazon::Associates::FilesystemCache.expects(:perform_sweep).once
      
      do_request
    end
    
    should "create a timestamp file after performing a sweep" do
      Amazon::Associates::FilesystemCache.expects(:sweep_time_expired?).once.returns(true)
      
      do_request
      assert FileTest.exists?(File.join(CACHE_PATH, ".amz_timestamp"))
    end
    
    should "purge the cache when performing a sweep" do
      (0..9).each do |n| 
        test = File.open(File.join(CACHE_PATH, "test_file_#{n}"), "w")
        test.puts Time.now
        test.close
      end
      
      Amazon::Associates::FilesystemCache.expects(:sweep_time_expired?).once.returns(true)
      do_request
      
      (0..9).each do |n|
        assert !FileTest.exists?(File.join(CACHE_PATH, "test_file_#{n}"))
      end
    end
    
  end

  protected
  def do_request
    @resp = Amazon::Associates.item_lookup("0974514055")
  end
end
