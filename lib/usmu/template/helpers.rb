
module Usmu
  # This module is a namespace for all the different types of templates in use by Usmu. It has no functionality
  # attached to it directly.
  module Template
    # Helper functions that get imported into the local scope of templates
    class Helpers
      # Create a new Helpers instance. These are created on demand as needed by templates, there is not a singleton
      # instance.
      def initialize(configuration)
        @configuration = configuration
      end

      # Finds and renders a named include.
      #
      # @param [String] name
      #   The name of the include file. Should not include file extension.
      # @param [Hash] args
      #   The named arguments to provide to the include file. These are incorporated as additional
      #   metadata available to the include file.
      # @return [String] The rendered file.
      #
      # @api template_helpers
      def include(name, args = {})
        inc = Usmu::Template::Include.find_include(@configuration, name)
        inc.arguments = args
        inc.render
      end
    end
  end
end
