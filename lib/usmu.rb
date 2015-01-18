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
  @log.appenders = Logging.appenders.stdout(
      'usmu-stdout',
      :level => :info,
      :layout => Logging.layouts.pattern(
          :pattern => '%m\n',
          :color_scheme => 'console',
      ),
  )

  # Globbing flags. Correct across 1.9.3 and 2.0+, enabling as many features as available
  FILE_GLOB_FLAGS = defined?(File::FNM_EXTGLOB) ? File::FNM_EXTGLOB | File::FNM_PATHNAME : File::FNM_PATHNAME

  # Enable logging of all events to the console
  #
  # @return [void]
  def self.verbose_logging
    Logging.appenders['usmu-stdout'].level = :all
    nil
  end

  # Disable all log messages other than errors. Warnings will be suppressed.
  #
  # @return [void]
  def self.quiet_logging
    Logging.appenders['usmu-stdout'].level = :error
    nil
  end

  # Adds a file-based logger
  #
  # @param [String] filename Filename of the file to log to.
  # @return [void]
  def self.add_file_logger(filename)
    @log.add_appenders(Logging.appenders.file(filename, :filename => filename, :level => :all))
    nil
  end

  # :nocov:
  # This is primarily a testing helper

  # Disables stdout logging across the application. This is used to hide stack traces but still log them to the file
  # log if it is in use.
  #
  # @return [void]
  def self.disable_stdout_logging
    @log.remove_appenders('usmu-stdout')
    nil
  end
  # :nocov:

  # @return [Usmu::Plugin] a handler to the plugin interface
  def self.plugins
    @plugins ||= Usmu::Plugin.new
  end

  def self.load_lazy_tilt_modules
    # There be magic here. Not nice, but gets the job done. Tilt's data structure here is a little unusual.
    Tilt.default_mapping.lazy_map.map {|pair| pair[1]}.map {|i| i.map {|j| j[1]}}.flatten.uniq.each do |f|
      begin
        require f
        @log.debug("Loaded #{f}")
      rescue LoadError => e
        @log.debug("Failed to load #{f}: #{e.inspect}")
      end
    end
  end
end

%W{
  usmu/version
  usmu/configuration
  usmu/metadata_service
  usmu/site_generator
  usmu/plugin
  usmu/plugin/core
  usmu/template/helpers
  usmu/template/include
  usmu/template/layout
  usmu/template/page
  usmu/template/static_file
}.each { |f| require f }
