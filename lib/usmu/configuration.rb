require 'yaml'

module Usmu
  # This class is used to represent a configuration file. This file should be a YAML file and called `usmu.yml`
  # by default.
  class Configuration
    @log = Logging.logger[self]

    # @!attribute [r] config_file
    # @return [String] the name of the file used to load the configuration.
    attr_reader :config_file
    # @!attribute [r] config_file
    # @return [String] the folder that the configuration was loaded from.
    attr_reader :config_dir

    # Load a configuration from a YAML file on disk.
    #
    # @return [Usmu::Configuration]
    def self.from_file(filename)
      @log.debug("Loading configuration from #{filename}")
      from_hash(YAML.load_file(filename), filename)
    end

    # Load a configuration from a hash.
    #
    # @return [Usmu::Configuration]
    def self.from_hash(hash, config_path = nil)
      self.new(hash, config_path)
    end

    # @!attribute [r] source_path
    # @return [String] the full path to the source folder
    def source_path
      get_path @config['source'] || 'src'
    end

    # @!attribute [r] destination_path
    # @return [String] the full path to the destination folder
    def destination_path
      get_path @config['destination'] || 'site'
    end

    # @!attribute [r] layouts_path
    # @return [String] the full path to the layouts folder
    def layouts_path
      get_path @config['layouts'] || 'layouts'
    end

    # An index accessor to directly access the configuration file. It should be noted that `['source']` and
    # `#source_path` and other similar pairs will have different values. `['source']` is the raw value from the
    # configuration file while the latter is a path on the system, potentially altered by the path from the current
    # working directory to the configuration file and other factors. The accessor functions such as `#source_path`
    # should be preferred for most usages.
    #
    # @param [String, Symbol] index The index to return.
    # @return [Array, Hash, String, Symbol] Returns a value from the hash loaded from YAML. The type of value will
    #   ultimately depend on the configuration file and the index provided.
    def [](index)
      @config[index]
    end

    private

    # This class has a private constructor.
    #
    # @see Usmu::Configuration.from_file
    # @see Usmu::Configuration.from_hash
    def initialize(hash, config_path)
      @log = Logging.logger[self]
      @config = hash
      @config_file = config_path
      @config_dir = config_path ? File.dirname(config_path) : nil
    end

    # Helper function to transform a relative path in the configuration file to a relative path from the current
    # working directory.
    #
    # @return [String]
    def get_path(path)
      if @config_dir.nil?
        path
      else
        File.join(@config_dir, path)
      end
    end
  end
end
