module FilesystemTestHelper
  @@cache_path = File.dirname(__FILE__) + "/cache/"

  protected
  VALID_CACHING_OPTIONS = {
     :cache_path => @@cache_path,
     :disk_quota => 200
  }

  def get_valid_caching_options
    #configure Amazon library for filesystem caching
    Amazon::Associates.configure do |options|
      options.merge!(:caching_strategy => :filesystem,
                     :caching_options => VALID_CACHING_OPTIONS)
    end
  end

  def destroy_caching_options
    #reset caching to off
    Amazon::Associates.configure do |options|
      options.delete(:caching_strategy)
      options.delete(:caching_options)
    end
  end

  def get_cache_directory
    #make the caching directory
    FileUtils.makedirs(@@cache_path)
  end

  def destroy_cache_directory
    #remove all the cache files
    FileUtils.rm_rf(@@cache_path)
  end
end