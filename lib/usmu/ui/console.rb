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

      # @param [Array<String>] args Command line arguments, ie. ARGV.
      def initialize(args)
        @log = Logging.logger[self]
        initialize_logging args
        @commander = initialize_commander(args)

        Usmu.plugins.load_plugins
        Usmu.plugins.invoke :commands, self, @commander

        @commander.default_command :generate
        @commander.run!
      end

      # Load a configuration from a file
      #
      # @param [String] config Name of configuration file to load
      # @return [Usmu::Configuration] the configuration for the site we will generate.
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
        @configuration
      end

      private

      def initialize_logging(args)
        i = 0
        while i < args.length
          case args[i]
            when '-v', '--verbose'
              args.delete_at i
              Usmu.verbose_logging
            when '-q', '--quiet'
              args.delete_at i
              Usmu.quiet_logging
            when '--log'
              if args.length > i + 1
                args.delete_at i
                path = args.delete_at i
                Usmu.add_file_logger path
              else
                i += 1
              end
            else
              i += 1
          end
        end
      end

      # Helper function to setup a Commander runner
      # @return [Commander::Runner]
      def initialize_commander(args)
        commander = Commander::Runner.new args

        commander.program :version, Usmu::VERSION
        commander.program :description, 'Static site generator powered by Tilt'
        commander.program :int_message, 'Interrupt received, closing...'

        commander.global_option('--config STRING', String, &method(:load_configuration))
        # Logging options are manually processed in #initialize_logging, but included here for user documentations sake
        commander.global_option('-v', '--verbose')
        commander.global_option('-q', '--quiet')
        commander.global_option('--log STRING', String)

        commander
      end
    end
  end
end
