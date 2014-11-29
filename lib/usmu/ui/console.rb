require 'usmu'
require 'commander'

module Usmu
  module Ui
    # This is the CLI UI controller. This is initialised by the usmu binary to control the generation process.
    class Console
      # @!attribute [r] site_generator
      # @return [Usmu::SiteGenerator]
      attr_reader :site_generator

      # @!attribute [r] configuration
      # Do not access this till your command starts running, eg. in Hooks#commands, otherwise you may not get the right
      # value for the configuration as option parsing may not have happened yet.
      # @return [Usmu::Configuration] the configuration for the site we will generate.
      def configuration
        @configuration || load_configuration('usmu.yml')
      end

      def initialize(args)
        @log = Logging.logger[self]
        @commander = Commander::Runner.new args

        @commander.program :version, Usmu::VERSION
        @commander.program :description, 'Static site generator powered by Tilt'
        @commander.program :int_message, 'Interrupt received, closing...'

        @commander.global_option('-v', '--verbose') { Usmu.verbose_logging }
        @commander.global_option('-q', '--quiet') { Usmu.quiet_logging }
        @commander.global_option('--log STRING', String) {|log| Usmu.add_file_logger(log) }
        @commander.global_option('--config STRING', String, &method(:load_configuration))

        Usmu.plugins.load_plugins
        Usmu.plugins.invoke :commands, self, @commander

        @commander.default_command :generate
        @commander.run!
      end

      def load_configuration(config)
        @log.info("Usmu v#{Usmu::VERSION}")
        @log.info('')

        if File.readable? config
          @configuration = Usmu::Configuration.from_file(config)
          @log.info("Configuration: #{config}")
        else
          @log.fatal("Unable to find configuration file at #{config}")
          raise
        end
      end
    end
  end
end
