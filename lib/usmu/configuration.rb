require 'yaml'

module Usmu
  class Configuration
    attr_reader :config_file
    attr_reader :config_dir

    def self.from_file(filename)
      from_hash(YAML.load_file(filename), filename)
    end

    def self.from_hash(hash, config_path = nil)
      self.new(hash, config_path)
    end

    def source_path
      get_path @config['source'] || 'src'
    end

    def destination_path
      get_path @config['destination'] || 'site'
    end

    def layouts_path
      get_path @config['layouts'] || 'layouts'
    end

    def [](index)
      @config[index]
    end

    private

    def initialize(hash, config_path)
      @config = hash
      @config_file = config_path
      @config_dir = config_path ? File.dirname(config_path) : nil
    end

    def get_path(path)
      if @config_dir.nil?
        path
      else
        File.join(@config_dir, path)
      end
    end
  end
end
