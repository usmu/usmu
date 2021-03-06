require 'fileutils'
require 'usmu/collections'
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
      @configuration.layouts_files.map {|l| Template::Layout.new(@configuration, l, @configuration.layouts_metadata.metadata(l)) }
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
      @renderables ||= begin
        rs = @configuration.source_files.map do |filename|
          metadata = @configuration.source_metadata.metadata(filename)
          if Template::Layout.is_valid_file?('source', filename) && (!metadata['static'])
            Template::Page.new(@configuration, filename, metadata)
          else
            Template::StaticFile.new(@configuration, filename, metadata)
          end
        end

        Usmu.plugins.alter(:renderables, rs, self)
      end
    end

    # Generate the website according to the configuration given.
    #
    # @return [void]
    def generate
      @log.info("Source: #{@configuration.source_path}")
      @log.info("Destination: #{@configuration.destination_path}")
      @log.info('')

      renderables.each &method(:generate_page)
      nil
    end

    # Returns an interface for interacting with collections defined in this site.
    #
    # @return [Usmu::Collections]
    def collections
      @collections ||= Collections.new(self)
    end

    # Refresh information about this site.
    def refresh
      collections.refresh
      nil
    end

    private

    # Helper function to generate a page
    #
    # @param [Usmu::Template::Page] page
    def generate_page(page)
      output_filename = page.output_filename
      @log.success("creating #{output_filename}...")
      @log.debug("Rendering #{output_filename} from #{page.name}")
      file = File.join(@configuration.destination_path, output_filename)
      directory = File.dirname(file)

      unless File.directory?(directory)
        FileUtils.mkdir_p(directory)
      end

      File.write file, page.render

      FileUtils.touch file, mtime: page.mtime
      nil
    end
  end
end
