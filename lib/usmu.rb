require 'logging'
require 'rubygems'

Logging.init :debug, :info, :success, :warn, :error, :fatal
Logging.color_scheme(
    'console',
    :lines => {
      :success  => :green,
      :warn  => :yellow,
      :error => :red,
      :fatal => :red,
    },
)

# This module contains all the code for the Usmu site generator
module Usmu
  @log = Logging.logger['Usmu']
  @log.level = :all
  @log.additive = false
  @log.appenders = Logging.appenders.stdout(
      'usmu-stdout',
      :level => :info,
      :layout => Logging.layouts.pattern(
          :pattern => '%m\n',
          :color_scheme => 'console',
      ),
  )

  # Adds a file-based logger
  #
  # @param [String] filename Filename of the file to log to.
  # @return [void]
  def self.add_file_logger(filename)
    @log.add_appenders(Logging.appenders.file(filename, :filename => filename, :level => :all))
    nil
  end

  # Disables stdout logging across the application. This is used to hide stack traces but still log them to the file
  # log if it is in use.
  #
  # @return [void]
  def self.disable_stdout_logging
    @log.remove_appenders('usmu-stdout')
    nil
  end

  # Loads all plugins that are available as gems. This is determined by looking at the gem's name. Anything prefixed
  # with the string 'usmu-' will be recognised as a plugin. This will load the gem according to the RubyGems
  # recommendations for naming schemes. A gem named `usmu-s3_uploader` will be loaded by requiring the path
  # `'usmu/s3_loader'` and then then the class `Usmu::S3Loader` will be instantiated as the plugins interface.
  #
  # @return [void]
  def self.load_plugins
    Gem::Specification.find_all { |s| s.name =~ /^usmu-/ }.each do |spec|
      load_path = spec.name.gsub('-', '/')
      # Only load once in case there's multiple versions installed. rubygems will only load one version that
      # should work anyway. If the user is using Bundler there will only be one version available to include.
      if require load_path
        klass = load_path.split('/').map {|s| s.split('_').map(&:capitalize).join }.join('::')
        @log.debug("Loading plugin #{klass} from '#{load_path}'")
        plugins.push Object.const_get(klass).new
      end
    end
  end

  # @!attribute [r] plugins
  # @return [Array] a list of all plugins discovered and loaded.
  def self.plugins
    @plugins ||= []
  end
end

%W{
  usmu/version
  usmu/configuration
  usmu/static_file
  usmu/layout
  usmu/page
  usmu/site_generator
}.each { |f| require f }
