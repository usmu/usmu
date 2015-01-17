require 'usmu/template/layout'

module Usmu
  module Template
    # Represents a page in the source directory of the website.
    class Include < Layout

      private

      # Preserved version of the layout metadata logic
      # @see Usmu::Template::Layout#metadata
      alias :layout_metadata :metadata

      public

      # @!attribute [rw] arguments
      # @return [Hash] the arguments associated with this include
      attr_accessor :arguments

      # Static method to create an include for a given configuration by it's name if it exists. This differs from
      # `#initialise` in that it allows different types of values to be supplied as the name and will not fail if name
      # is nil
      #
      # @param configuration [Usmu::Configuration] The configuration to use for the search
      # @param name [String]
      #   If name is a string then search for a template with that name. Name here should not include
      #   file extension, eg. body not body.slim. If name is not a string then it will be returned verbatim. This means
      #   that name is nilable and can also be passed in as an Usmu::Template::Include already for testing purposes.
      # @return [Usmu::Layout]
      def self.find_include(configuration, name)
        if name === 'none'
          nil
        elsif name.class.name == 'String'
          Dir["#{configuration.includes_path}/#{name}.*"].each do |f|
            filename = File.basename(f)
            if filename != "#{name}.meta.yml"
              path = f[(configuration.includes_path.length + 1)..f.length]
              return new(configuration, path, configuration.includes_metadata.metadata(path))
            end
          end
          nil
        else
          name
        end
      end

      # @!attribute [r] metadata
      # @return [Hash] the metadata associated with this layout.
      #
      # Returns the metadata associated with this layout.
      #
      # This will include any metadata from parent templates and default metadata
      def metadata
        meta = layout_metadata
        # Includes must never allow layout inheritance.
        meta['layout'] = nil

        meta
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
        @configuration.includes_path
      end

      private

      # Utility function which collates variables to pass to the template engine.
      #
      # @return [Hash]
      def get_variables(variables)
        args = {}
        arguments.each do |i, value|
          args[i.class.name == 'String' ? i : i.to_s] = value
        end

        {'site' => @configuration}.deep_merge!(metadata).deep_merge!(args).deep_merge!(variables)
      end
    end
  end
end
