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
        @args = args
        @configuration = Usmu::Configuration.from_file(File.join(args[0] || '.', 'usmu.yml'))
      end

      # This will run the command as setup in `#initialize`
      #
      # @return [void]
      def execute
        Usmu::SiteGenerator.new(@configuration).generate
      end
    end
  end
end
