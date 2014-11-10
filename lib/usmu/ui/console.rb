require 'usmu'
require 'trollop'

module Usmu
  module Ui
    class Console
      attr_reader :configuration

      def initialize(args)
        @args = args
        @configuration = Usmu::Configuration.from_file(File.join(args[0], 'usmu.yml'))
      end

      def execute
        Usmu::SiteGenerator.new(@configuration).generate
      end
    end
  end
end
