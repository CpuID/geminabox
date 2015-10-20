require "fileutils"
module Geminabox
  class Geminabox::DiskCache
    attr_reader :root_path

    def initialize(root_path, hooks_object = nil)
      @logger = Logger.new(STDOUT)
      @logger.info "Instantiated a Geminabox::DiskCache object."
      @root_path = root_path
      if ! hooks_object.nil?
        @hooks = hooks_object
      end
      ensure_dir_exists!
    end

    def flush_key(key)
      path = path(key_hash(key))
      FileUtils.rm_f(path)
    end

    def flush
      FileUtils.rm_rf(root_path)
      ensure_dir_exists!
    end

    def cache(key)
      key_hash = key_hash(key)
      read(key_hash) || write(key_hash, yield)
    end

    def marshal_cache(key)
      key_hash = key_hash(key)
      marshal_read(key_hash) || marshal_write(key_hash, yield)
    end

  protected

    def ensure_dir_exists!
      FileUtils.mkdir_p(root_path)
    end

    def key_hash(key)
      Digest::SHA256.hexdigest(key)
    end

    def path(key_hash)
      File.join(root_path, key_hash)
    end

    def read(key_hash)
      read_int(key_hash) { |path| File.read(path) }
    end

    def marshal_read(key_hash)
      read_int(key_hash) { |path| Marshal.load(File.open(path)) }
    end

    def read_int(key_hash)
      path = path(key_hash)
      @hooks.pre_read path
      yield(path) if File.exists?(path)
    end

    def write(key_hash, value)
      write_int(key_hash) { |f| f << value }
      value
    end

    def marshal_write(key_hash, value)
      write_int(key_hash) { |f| Marshal.dump(value, f) }
      value
    end

    def write_int(key_hash)
      path_key_hash = path(key_hash)
      File.open(path_key_hash, 'wb') { |f| yield(f) }
      @hooks.post_write path_key_hash
    end

  end
end
