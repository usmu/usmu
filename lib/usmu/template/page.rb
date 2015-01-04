require 'usmu/template/layout'

module Usmu
  module Template
    # Represents a page in the source directory of the website.
    class Page < Layout

      # @param configuration [Usmu::Configuration] The configuration for the website we're generating.
      # @param name [String] The name of the file in the source directory.
      # @param type [String] The type of template to use with the file. Used for testing purposes.
      # @param content [String] The content of the file. Used for testing purposes.
      # @param metadata [String] The metadata for the file. Used for testing purposes.
      def initialize(configuration, name, type = nil, content = nil, metadata = nil)
        super(configuration, name, type, content, metadata)

        current_parent = parent
        until current_parent.nil?
          @log.debug("Injecting page #{name} into #{current_parent.name}")
          current_parent['page'] = self
          current_parent = current_parent.parent
        end
      end

      protected

      # @!attribute [r] content_path
      # @return [string] the base path to the files used by this class.
      #
      # Returns the base path to the files used by this class.
      #
      # This folder should be the parent folder for the file named by the name attribute.
      #
      # @see #name
      def content_path
        @configuration.source_path
      end
    end
  end
end
