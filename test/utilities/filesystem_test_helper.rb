module FilesystemTestHelper
  CACHE_PATH = File.dirname(__FILE__) + "/cache/"

  protected
  def valid_caching_options(path = nil)
    FileUtils.mkdir_p(path) unless path.nil?
    {
       :cache_path => path || CACHE_PATH,
       :disk_quota => 200
    }
  end

  def get_valid_caching_options(path = nil)
    #configure Amazon library for filesystem caching
    Amazon::Associates.configure do |options|
      options.merge!(:caching_strategy => :filesystem,
                     :caching_options => valid_caching_options(path))
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
    FileUtils.makedirs(CACHE_PATH)
  end

  def destroy_cache_directory
    #remove all the cache files
    FileUtils.rm_rf(CACHE_PATH)
  end
end