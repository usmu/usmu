require 'usmu'
require 'trollop'

module Usmu
  module Ui
    # This is the CLI UI controller. This is initialised by the usmu binary to control the generation process.
    class Console
      # @!attribute [r] configuration
      # @return [Usmu::Configuration] the configuration for the site we will generate.
      attr_reader :configuration

      # @param [Array<String>] args Command line arguments. Typically ARGV should be passed here.
      def initialize(args)
        @log = Logging.logger[self]
        @log.info("Usmu v#{Usmu::VERSION}")
        @log.info('')
        @args = args

        config_file = File.join(@args[0] || '.', 'usmu.yml')
        if File.readable? config_file
          @configuration = Usmu::Configuration.from_file(config_file)
          @log.info("Configuration: #{config_file}")
        else
          @log.fatal("Unable to find configuration file at #{config_file}")
          exit 1
        end
      end

      # This will run the command as setup in `#initialize`
      #
      # @return [void]
      def execute
        Usmu::SiteGenerator.new(@configuration).generate
      rescue StandardError => e
        @log.error('There was an unforeseen error, please use --trace or --log for more details.')
        @log.error(e.message)
        Usmu.disable_stdout_logging
        e.backtrace.each {|l| @log.error(l)}
      end
    end
  end
end
