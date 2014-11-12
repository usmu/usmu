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
        @args = args.dup
        @opts = Trollop::options(args) do
          version "Usmu v#{Usmu::VERSION}"

          banner "Usmu v#{Usmu::VERSION}"
          banner ''
          banner "Usage: #{$0} [options]"
          banner ''

          opt :config, 'Specify a configuration file.', :type => :string, :default => 'usmu.yml'
          opt :verbose, 'Output more information to the console.'
          opt :log, 'Log to a file', :type => :string
          opt :trace, 'Show full exception traces'
        end

        Logging.appenders['usmu-stdout'].level = :all if @opts[:verbose]
        Usmu.add_file_logger @opts[:log] if @opts[:log]

        Usmu.load_plugins

        @log.info("Usmu v#{Usmu::VERSION}")
        @log.info('')

        if File.readable? @opts[:config]
          @configuration = Usmu::Configuration.from_file(@opts[:config])
          @log.info("Configuration: #{@opts[:config]}")
        else
          @log.fatal("Unable to find configuration file at #{@opts[:config]}")
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
        Usmu.disable_stdout_logging unless @opts[:trace]
        e.backtrace.each {|l| @log.error(l)}
      end
    end
  end
end
