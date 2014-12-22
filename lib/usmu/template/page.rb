require 'usmu/template/layout'

module Usmu
  module Template
    # Represents a page in the source directory of the website.
    class Page < Layout
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
