require 'fileutils'

module Usmu
  class SiteGenerator
    def initialize(configuration)
      @configuration = configuration
    end

    def layouts
      get_renderables @configuration.layouts_path, true
    end

    def renderables
      get_renderables @configuration.source_path, false
    end

    def pages
      renderables.select {|r| r.class.name != 'Usmu::StaticFile'}
    end

    def files
      renderables.select {|r| r.class.name == 'Usmu::StaticFile'}
    end

    def generate
      renderables.each do |page|
        file = File.join(@configuration.destination_path, page.output_filename)
        directory = File.dirname(file)

        unless File.directory?(directory)
          FileUtils.mkdir_p(directory)
        end

        File.write file, page.render
      end
    end

    private

    def get_renderables(directory, layout)
      Dir["#{directory}/**/*"].select {|f| !f.match(/\.meta.yml$/) }.map do |f|
        filename = f[(directory.length + 1)..f.length]
        if layout
          Usmu::Layout.new(@configuration, filename)
        else
          if Usmu::Layout.is_valid_file? 'source', filename
            Usmu::Page.new(@configuration, filename)
          else
            Usmu::StaticFile.new(@configuration, filename)
          end
        end
      end
    end
  end
end
