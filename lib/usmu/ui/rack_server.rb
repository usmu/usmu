
module Usmu
  module Ui
    class RackServer
      def initialize(configuration)
        @log = Logging.logger[self]
        @configuration = configuration
        @index = configuration['serve', 'index', default: 'index.html']
      end

      def call(env)
        generator = @configuration.generator
        
        path = env['PATH_INFO'][1...env['PATH_INFO'].length]
        @log.info "Received a request for: #{path}"
        path = File.join(path, @index) if File.directory? File.join(@configuration.source_path, path)
        path = path[1...path.length] if path[0] == '/'
        @log.info "Serving: #{path}"

        valid = generator.renderables.select {|r| r.output_filename == path }

        if valid.length > 0
          generator.refresh
          page = valid[0]
          type = case page.output_filename[page.output_filename.rindex('.')...page.output_filename.length]
                   when '.html', '.php'
                     'text/html'
                   when '.css'
                     'text/css'
                   when '.js'
                     'text/javascript'
                   else
                     'text/plain'
                 end

          ['200', {'Content-Type' => type}, [page.render]]
        else
          ['404', {'Content-Type' => 'text/html'}, ['<!DOCTYPE html><h1>File not found.</h1>']]
        end
      end

      def shutdown
      end
    end
  end
end
