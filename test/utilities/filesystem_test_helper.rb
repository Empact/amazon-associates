module FilesystemTestHelper
  CACHE_TEST_PATH = File.join(File.dirname(__FILE__), "../amazon/caching/cache/")

protected
  def set_valid_caching_options(path = nil)
    path ||= File.join(File.dirname(__FILE__), "cache")
    if @path
      raise "Expected same path: #{path} != #{@path}" if path != @path
      return
    end

    @path = path

    #configure Amazon library for filesystem caching
    FileUtils.mkdir_p(@path)
    Amazon::Associates.configure do |options|
      options.merge!(:caching_strategy => :filesystem,
                     :caching_options => {
                         :cache_path => @path,
                         :disk_quota => 200
                     })
    end
  end

  def reset_cache
    #reset caching to off
    Amazon::Associates.configure do |options|
      options.delete(:caching_strategy)
      options.delete(:caching_options)
    end

    #remove all the cache files
    FileUtils.rm_rf(@path)
  end
end
