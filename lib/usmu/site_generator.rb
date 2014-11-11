require 'fileutils'

module Usmu
  # This is the class that brings everything together to generate a new website.
  class SiteGenerator
    # @param [Usmu::Configuration] configuration The configuration to use for generating the website
    def initialize(configuration)
      @log = Logging.logger[self]
      @configuration = configuration
    end

    # @!attribute [r] layouts
    # @return [Array<Usmu::Layout>] a list of layouts available in this website.
    def layouts
      get_renderables @configuration.layouts_path, true
    end

    # @!attribute [r] renderables
    # @return [Array<Usmu::StaticFile>] a list of renderable files from the source folder.
    #   will be a subclass of this class.
    # @see Usmu::StaticFile
    #
    # Returns a list of renderable files from the source folder.
    #
    # The only guarantee made for individual files is that they will conform to the interface defined by
    # Usmu::StaticFile and thus be renderable, however most files will be one of the subclasses of that class.
    def renderables
      get_renderables @configuration.source_path, false
    end

    # @!attribute [r] pages
    # @return [Array<Usmu::Page>] a list of pages from the source folder. This is any file in the source folder which
    #   is not static.
    def pages
      renderables.select {|r| r.class.name != 'Usmu::StaticFile'}
    end

    # @!attribute [r] files
    # @return [Array<Usmu::StaticFile>] a list of static files from the source folder.
    def files
      renderables.select {|r| r.class.name == 'Usmu::StaticFile'}
    end

    # Generate the website according to the configuration given.
    #
    # @return [void]
    def generate
      @log.info("Source: #{@configuration.source_path}")
      @log.info("Destination: #{@configuration.destination_path}")

      renderables.each do |page|
        @log.success("creating #{page.output_filename}...")
        file = File.join(@configuration.destination_path, page.output_filename)
        directory = File.dirname(file)

        unless File.directory?(directory)
          FileUtils.mkdir_p(directory)
        end

        File.write file, page.render
      end
      nil
    end

    private

    # Helper function to search a directory recursively and return a list of files that are renderable.
    #
    # @param [String] directory the directory to search
    # @param [Boolean] layout is this directory a layouts_path
    # @return [Array<Usmu::Layout>, Array<Usmu::StaticFile>] Either an array of Layouts or StaticFiles in the directory
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
