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

  def self.plugins
    @plugins || Usmu::Plugin.new
  end
end

%W{
  usmu/version
  usmu/configuration
  usmu/static_file
  usmu/layout
  usmu/page
  usmu/site_generator
  usmu/plugin
  usmu/plugin/core
}.each { |f| require f }
