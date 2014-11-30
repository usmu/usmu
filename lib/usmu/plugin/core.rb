require 'fileutils'

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

        c.command(:init) do |command|
          command.syntax = 'usmu init [path]'
          command.description = 'Initialise a new website in the given path, or the current directory if none given.'
          command.action &method(:command_init)
        end
      end

      # @return [void]
      def command_generate(args, options)
        @site_generator = Usmu::SiteGenerator.new(@ui.configuration)
        @site_generator.generate
      end

      def command_init(args, options)
        @log.info("Usmu v#{Usmu::VERSION}")
        @log.info('')

        if args.length > 1
          @log.fatal('Only one path allowed to be initialised at a time.')
          raise
        end

        path = args.length == 1 ? args.shift : '.'
        from = File.realpath(File.join(File.dirname(__FILE__), '../../../share/init-site'))

        @log.info("Copying #{from} -> #{path}")
        Dir["#{from}/**/{*,.??*}"].each do |file|
          output_name = file[(from.length + 1)..file.length]
          @log.success "Creating #{output_name}..."
          unless File.directory? file
            output_path = "#{path}/#{output_name}"
            FileUtils.mkdir_p File.dirname(output_path) unless File.directory? File.dirname(output_path)
            FileUtils.copy(file, output_path)
          end
        end
      end
    end
  end
end
