require 'usmu/configuration'

module Usmu
  module Template
    # Represents a static file which should be transferred to the destination unchanged. This also acts as the base
    # class for all layouts and page types. The basic interface defined here is used to process all types of files.
    class StaticFile
      include Usmu::Helpers::Indexer

      # @!attribute [r] name
      # @return [String] the name of the file in the source directory
      attr_reader :name

      indexer :metadata

      # @param configuration [Usmu::Configuration] The configuration for the website we're generating.
      # @param name [String] The name of the file in the source directory.
      # @param metadata [Hash] The metadata for the file.
      # @param type [String] The type of template to use with the file. Not used for StaticFile.
      #   Used for testing purposes.
      # @param content [String] The content of the file. Used for testing purposes.
      def initialize(configuration, name, metadata, type = nil, content = nil)
        @log = Logging.logger[self]
        @log.debug("Creating <##{self.class.name} @name=\"#{name}\">")

        @configuration = configuration
        @name = name
        @metadata = metadata
        @type = type
        @content = content
      end

      # Renders the file with any templating language required and returns the result
      #
      # @param variables [Hash] Variables to be used in the template.
      # @return [String] The rendered file
      def render(variables = {})
        @content || File.read(input_path)
      end

      # @!attribute [r] input_path
      # @return [String] the full path to the file in the source directory
      def input_path
        File.join(@configuration.source_path, @name)
      end

      def metadata
        {}
      end

      # @!attribute [r] output_filename
      # @return [String] the filename to use in the output directory.
      #
      # Returns the filename to use for the output directory with any modifications to the input filename required.
      def output_filename
        @name
      end

      # @!attribute [r] mtime
      # @return [Fixnum] The modification time of this file.
      def mtime
        input_path.nil? ? Time.now.to_i : File.stat(input_path).mtime
      end

      def inspect
        "\#<#{self.class}:#{'0x%08x' % __id__} #{@name} => #{output_filename}>"
      end

      def ==(other)
        return false unless self.class == other.class

        self.input_path == other.input_path && self.output_filename == other.output_filename
      end
    end
  end
end
