
module Usmu
  # Represents a static file which should be transferred to the destination unchanged. This also acts as the base
  # class for all layouts and page types. The basic interface defined here is used to process all types of files.
  class StaticFile
    @log = Logging.logger[self]

    # @!attribute [r] name
    # @return [String] the name of the file in the source directory
    attr_reader :name

    # @param configuration [Usmu::Configuration] The configuration for the website we're generating.
    # @param name [String] The name of the file in the source directory.
    # @param type [String] The type of template to use with the file. Not used for StaticFile.
    #   Used for testing purposes.
    # @param content [String] The content of the file. Used for testing purposes.
    # @param metadata [String] The metadata for the file. Used for testing purposes.
    def initialize(configuration, name, type = nil, content = nil, metadata = nil)
      @configuration = configuration
      @name = name
      @type = type
      @content = content
    end

    # Renders the file with any templating language required and returns the result
    #
    # @param variables [Hash] Variables to be used in the template.
    # @return [String] The rendered file
    def render(variables = {})
      @content || File.read(File.join(@configuration.source_path, @name))
    end

    # @!attribute [r] output_filename
    # @return [String] the filename to use in the output directory.
    #
    # Returns the filename to use for the output directory with any modifications to the input filename required.
    def output_filename
      @name
    end
  end
end
