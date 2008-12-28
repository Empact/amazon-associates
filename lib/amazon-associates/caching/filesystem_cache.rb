require "fileutils"
require "find"

begin
  require 'md5'
rescue LoadError
  require 'digest/md5'
end

module Amazon
  module Associates
    module FilesystemCache
        #disk quota in megabytes
        DEFAULT_DISK_QUOTA = 200

        #frequency of sweeping in hours
        DEFAULT_SWEEP_FREQUENCY = 2

        def self.cache(request_url, response)
          path = self.cache_path
          cached_filename = Digest::SHA1.hexdigest(request_url)
          cached_folder = File.join(path, cached_filename[0..2])

          FileUtils.mkdir_p(cached_folder)

          destination = File.join(cached_folder, cached_filename)
          open(destination, "w") do |cached_file|
            Marshal.dump(response, cached_file)
          end
        end

        def self.get(request)
          path = self.cache_path
          cached_filename = Digest::SHA1.hexdigest(request)
          file_path = File.join(path, cached_filename[0..2], cached_filename)
          if FileTest.exists?(file_path)
            open(file_path) {|f| Marshal.load(f) }
          end
        end

        def self.initialize_options(options)
          #check for required options
          unless cache_options = options[:caching_options]
            raise ConfigurationError, "You must specify caching options for filesystem caching: :cache_path is required"
          end

          #default disk quota to 200MB
          @@disk_quota = cache_options[:disk_quota] || DEFAULT_DISK_QUOTA

          @@sweep_frequency = cache_options[:sweep_frequency] || DEFAULT_SWEEP_FREQUENCY

          @@cache_path = cache_options[:cache_path]

          if @@cache_path.nil? || !File.directory?(@@cache_path)
            raise ConfigurationError, "You must specify a cache path for filesystem caching"
          end
        end

        def self.sweep
          self.perform_sweep if must_sweep?
        end

        def self.disk_quota
          @@disk_quota
        end

        def self.sweep_frequency
          @@sweep_frequency
        end

        def self.cache_path
          @@cache_path
        end

        private
        def self.perform_sweep
          FileUtils.rm_rf(Dir.glob("#{@@cache_path}/*"))

          self.timestamp_sweep_performance
        end

        def self.timestamp_sweep_performance
          #remove the timestamp
          FileUtils.rm_rf(self.timestamp_filename)

          #create a new one its place
          File.open(self.timestamp_filename, "w") do |timestamp|
            timestamp.puts(Time.now)
          end
        end

        def self.must_sweep?
          sweep_time_expired? || disk_quota_exceeded?
        end

        def self.sweep_time_expired?
          FileTest.exists?(timestamp_filename) && Time.parse(File.read(timestamp_filename).chomp) < Time.now - (sweep_frequency * 3600)
        end

        def self.disk_quota_exceeded?
          cache_size > @@disk_quota
        end

        def self.timestamp_filename
          File.join(self.cache_path, ".amz_timestamp")
        end

        def self.cache_size
          size = 0
          Find.find(@@cache_path) do|f|
             size += File.size(f) if File.file?(f)
          end
          size / 1000000
        end
      end
    end
  end
