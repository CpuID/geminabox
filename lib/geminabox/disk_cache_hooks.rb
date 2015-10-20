module Geminabox
  class DiskCacheHooks
    attr_reader :logger

    def initialize (logger: Logger.new(STDOUT))
      @logger = logger
    end

    def self.pre_read (file_name)
      # No action required, default cache hook provider.
    end

    def self.post_write (file_name)
      # No action required, default cache hook provider.
    end
  end
end
