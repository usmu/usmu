
module Usmu
  class Plugin
    class Core
      def initialize
        @log = Logging.logger[self]
      end

      def commands(ui, c)
        @log.debug('Adding core console commands...')
        @ui = ui
        c.command(:generate) do |command|
          command.syntax = 'usmu generate'
          command.description = 'Generates your website using the configuration specified.'
          command.action &method(:command_generate)
        end
      end

      # @return [void]
      def command_generate(args, options)
        @site_generator = Usmu::SiteGenerator.new(@ui.configuration)
        @site_generator.generate
      end
    end
  end
end
