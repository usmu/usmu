require 'usmu'
require 'trollop'

module Usmu
  module Ui
    # This is the CLI UI controller. This is initialised by the usmu binary to control the generation process.
    class Console
      # @!attribute [r] configuration
      # @return [Usmu::Configuration] the configuration for the site we will generate.
      attr_reader :configuration
      # @!attribute [r] opts
      # @return [Hash] the command line options as passed by the user
      attr_reader :opts
      # @!attribute [r] site_generator
      # @return [Usmu::SiteGenerator]
      attr_reader :site_generator

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
          opt :quiet, 'Silence output to the console unless something goes wrong'
          opt :log, 'Log to a file', :type => :string
          opt :trace, 'Show full exception traces'
        end

        if @opts[:verbose]
          Usmu.verbose_logging
        elsif @opts[:quiet]
          Usmu.quiet_logging
        end
        if @opts[:log]
          Usmu.add_file_logger @opts[:log]
        end

        Usmu.load_plugins

        @log.info("Usmu v#{Usmu::VERSION}")
        @log.info('')

        if File.readable? @opts[:config]
          @configuration = Usmu::Configuration.from_file(@opts[:config])
          @log.info("Configuration: #{@opts[:config]}")
        else
          @log.fatal("Unable to find configuration file at #{@opts[:config]}")
          raise
        end

        @site_generator = Usmu::SiteGenerator.new(@configuration)
      end

      # This will run the command as setup in `#initialize`
      #
      # @return [void]
      def execute
        @site_generator.generate
      rescue StandardError => e
        @log.error('There was an unforeseen error, please use --trace or --log for more details.')
        @log.error(e.message)
        Usmu.disable_stdout_logging unless @opts[:trace]
        e.backtrace.each {|l| @log.error(l)}
        raise
      end
    end
  end
end
