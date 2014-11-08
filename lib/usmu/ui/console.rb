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

      end
    end
  end
end
