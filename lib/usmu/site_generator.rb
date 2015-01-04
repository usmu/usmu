require 'fileutils'
require 'usmu/configuration'
require 'usmu/template/page'
require 'usmu/template/static_file'

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
      @configuration.layouts_files.map {|l| Usmu::Template::Layout.new(@configuration, l) }
    end

    # @!attribute [r] renderables
    # @return [Array<Usmu::Template::StaticFile>] a list of renderable files from the source folder.
    #   will be a subclass of this class.
    # @see Usmu::StaticFile
    #
    # Returns a list of renderable files from the source folder.
    #
    # The only guarantee made for individual files is that they will conform to the interface defined by
    # Usmu::Template::StaticFile and thus be renderable, however most files will be one of the subclasses of that class.
    def renderables
      @configuration.source_files.map do |filename|
        if Usmu::Template::Layout.is_valid_file? 'source', filename
          Usmu::Template::Page.new(@configuration, filename)
        else
          Usmu::Template::StaticFile.new(@configuration, filename)
        end
      end
    end

    # @!attribute [r] pages
    # @return [Array<Usmu::Template::Page>] a list of pages from the source folder. This is any file in the source
    #   folder which is not static.
    def pages
      renderables.select {|r| r.class.name != 'Usmu::Template::StaticFile'}
    end

    # @!attribute [r] files
    # @return [Array<Usmu::Template::StaticFile>] a list of static files from the source folder.
    def files
      renderables.select {|r| r.class.name == 'Usmu::Template::StaticFile'}
    end

    # Generate the website according to the configuration given.
    #
    # @return [void]
    def generate
      @log.info("Source: #{@configuration.source_path}")
      @log.info("Destination: #{@configuration.destination_path}")
      @log.info('')

      renderables.each do |page|
        @log.success("creating #{page.output_filename}...")
        @log.debug("Rendering #{page.output_filename} from #{page.name}")
        file = File.join(@configuration.destination_path, page.output_filename)
        directory = File.dirname(file)

        unless File.directory?(directory)
          FileUtils.mkdir_p(directory)
        end

        File.write file, page.render
        FileUtils.touch file, :mtime => File.stat(page.input_path).mtime
      end
      nil
    end
  end
end
