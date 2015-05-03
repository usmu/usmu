require 'fileutils'
require 'rack'
require 'usmu/ui/rack_server'

module Usmu
  class Plugin
    # Usmu Core's plugin. We dog-food several plugin integration points.
    class Core
      # Basic constructor.
      def initialize
        @log = Logging.logger[self]
      end

      # We add two commands: `generate` and `init [path]`.
      #
      # @see #command_generate
      # @see #command_init
      # @see Usmu::Plugin::CoreHooks#commands
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

        c.command(:serve) do |command|
          command.syntax = 'usmu serve'
          command.description = 'Serve files processed files directly. This won\'t update files on disk, but you will be able to view your website as rendered.'
          command.action &method(:command_serve)
        end
      end

      # Command to generate a website.
      #
      # @param [Array<String>] args arguments passed by the user.
      # @param [Hash] options options parsed by Commander
      def command_generate(args, options)
        raise 'This command does not take arguments' unless args.empty?
        raise 'Invalid options' unless options.inspect.start_with? '<Commander::Command::Options '

        @ui.configuration.generator.generate
      end

      # Command to initialise a new website.
      #
      # @param [Array<String>] args arguments passed by the user.
      # @param [Hash] options options parsed by Commander
      def command_init(args, options)
        @log.info("Usmu v#{Usmu::VERSION}")
        @log.info('')

        raise 'Invalid options' unless options.inspect.start_with? '<Commander::Command::Options '
        if args.length > 1
          @log.fatal('Only one path allowed to be initialised at a time.')
          raise
        end

        path = args.length == 1 ? args.shift : '.'
        from = File.realpath(File.join(File.dirname(__FILE__), '../../../share/init-site'))

        @log.info("Copying #{from} -> #{path}")
        Dir["#{from}/**/{*,.??*}"].each {|f| init_copy_file(from, path, f) }
      end

      def command_serve(args, options)
        raise 'This command does not take arguments' unless args.empty?
        raise 'Invalid options' unless options.inspect.start_with? '<Commander::Command::Options '

        configuration = @ui.configuration
        @log.info('Starting webserver...')

        Rack::Handler::WEBrick.run Ui::RackServer.new(configuration),
                                   host: configuration['serve', 'host', default: 'localhost'],
                                   port: configuration['serve', 'port', default: 8080]
      end

      private

      attr_accessor :ui

      # Helper to copy a file.
      #
      # @param [String] from
      # @param [String] to
      # @param [String] file
      def init_copy_file(from, to, file)
        output_name = file[(from.length + 1)..file.length]
        @log.success "Creating #{output_name}..."
        unless File.directory? file
          output_path = "#{to}/#{output_name}"
          FileUtils.mkdir_p File.dirname(output_path) unless File.directory? File.dirname(output_path)
          FileUtils.copy(file, output_path)
        end
      end
    end
  end
end
