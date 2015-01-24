require 'yaml'
require 'usmu/metadata_service'
require 'usmu/helpers/indexer'

module Usmu
  # This class is used to represent a configuration file. This file should be a YAML file and called `usmu.yml`
  # by default.
  class Configuration
    include Usmu::Helpers::Indexer

    @log = Logging.logger[self]

    indexer :@config

    # @!attribute [r] config_file
    # @return [String] the name of the file used to load the configuration.
    attr_reader :config_file
    # @!attribute [r] config_dir
    # @return [String] the folder that the configuration was loaded from.
    attr_reader :config_dir

    # Load a configuration from a YAML file on disk.
    #
    # @return [Usmu::Configuration]
    def self.from_file(filename)
      raise ArgumentError, "File not found: #{filename}" if filename.nil? || (not File.exist? filename)
      @log.debug("Loading configuration from #{filename}")
      new(YAML.load_file(filename), filename)
    end

    # Load a configuration from a hash.
    #
    # @return [Usmu::Configuration]
    def self.from_hash(hash, config_path = nil)
      new(hash, config_path)
    end

    # @!attribute [r] source_path
    # @return [String] the full path to the source folder
    def source_path
      get_path self['source'] || 'src'
    end

    # @!attribute [r] source_files
    # @return [Array<String>] a list of renderable files in the source folder
    def source_files
      get_files source_path
    end

    def source_metadata
      @source_metadata ||= MetadataService.new(source_path)
    end

    # @!attribute [r] destination_path
    # @return [String] the full path to the destination folder
    def destination_path
      get_path self['destination'] || 'site'
    end

    # @!attribute [r] layouts_path
    # @return [String] the full path to the layouts folder
    def layouts_path
      get_path self['layouts'] || 'layouts'
    end

    # @!attribute [r] layouts_files
    # @return [Array<String>] a list of renderable files in the layouts folder
    def layouts_files
      get_files layouts_path
    end

    def layouts_metadata
      @layouts_metadata ||= MetadataService.new(layouts_path)
    end

    # @!attribute [r] layouts_path
    # @return [String] the full path to the layouts folder
    def includes_path
      get_path self['includes'] || 'includes'
    end

    # @!attribute [r] layouts_files
    # @return [Array<String>] a list of renderable files in the layouts folder
    def includes_files
      get_files includes_path
    end

    def includes_metadata
      @includes_metadata ||= MetadataService.new(includes_path)
    end

    # Returns an array of exclusions
    #
    # @return [Array]
    def exclude
      self['exclude'] || []
    end

    # @return [Usmu::SiteGenerator]
    def generator
      @generator ||= SiteGenerator.new(self)
    end

    private

    attr_reader :log
    attr_reader :config

    # This class has a private constructor.
    #
    # @see Usmu::Configuration.from_file
    # @see Usmu::Configuration.from_hash
    def initialize(hash, config_path)
      @log = Logging.logger[self]
      @config = hash
      @config_file = config_path
      @config_dir = if config_path
                      File.dirname(config_path)
                    end
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

    # Helper to determine if a filename is excluded according to the exclude configuration parameter.
    #
    # @return [Boolean]
    def excluded?(filename)
      exclude.each do |f|
        f += '**/*' if f.end_with? '/'
        return true if File.fnmatch(f, filename, FILE_GLOB_FLAGS)
      end
      false
    end

    # Helper function to search a directory recursively and return a list of files that are renderable.
    #
    # @param [String] directory the directory to search
    # @return [Array<Usmu::Layout>, Array<Usmu::StaticFile>] Either an array of Layouts or StaticFiles in the directory
    def get_files(directory)
      Dir["#{directory}/**/{*,.??*}"].
          select {|f| not File.directory? f }.
          select {|f| !f.match(/[\.\/]meta\.yml$/) }.
          map {|f| f[directory.length + 1, f.length] }.
          select {|f| not excluded? f }
    end
  end
end
