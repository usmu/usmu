require 'tilt'
require 'deep_merge'
require 'usmu/template/static_file'

module Usmu
  module Template
    # Class to represent files templated with a Tilt library. Most of the custom rendering logic is contained here.
    class Layout < StaticFile
      # @!attribute [r] type
      # @return [String] the type of file this is. This is used to determine which template engine to use.
      attr_reader :type

      # @param configuration [Usmu::Configuration] The configuration for the website we're generating.
      # @param name [String] The name of the file in the source directory.
      # @param type [String] The type of template to use with the file. Used for testing purposes.
      # @param content [String] The content of the file. Used for testing purposes.
      # @param metadata [String] The metadata for the file. Used for testing purposes.
      def initialize(configuration, name, type = nil, content = nil, metadata = nil)
        super(configuration, name)

        if type.nil?
          type = name.split('.').last
          unless ::Tilt.default_mapping[type]
            raise "Templates of type '#{type}' aren't currently supported by Tilt. " +
                  'Do you have the required gem installed?'
          end
        end
        @type = type
        path = File.join("#{content_path}", "#{name[0, name.length - type.length - 1]}")

        if content.nil?
          content = File.read("#{path}.#{type}")
        end
        @content = content

        if metadata.nil?
          meta_file = "#{path}.meta.yml"
          metadata = if File.exist? meta_file
            YAML.load_file(meta_file)
          else
            {}
          end
        end
        @metadata = metadata

        @parent = nil
        @parent = Layout.find_layout(configuration, self.metadata['layout'])
      end

      # @!attribute [r] metadata
      # @return [Hash] the metadata associated with this layout.
      #
      # Returns the metadata associated with this layout.
      #
      # This will include any metadata from parent templates and default metadata
      def metadata
        if @parent.nil?
          (@configuration['default meta'] || {}).dup.deep_merge!(@metadata)
        else
          @parent.metadata.deep_merge!(@metadata)
        end
      end

      # Renders the file with any templating language required and returns the result
      #
      # @param variables [Hash] Variables to be used in the template.
      # @return [String] The rendered file.
      def render(variables = {})
        content = template_class.new("#{@name}.#{@type}", 1, @configuration[provider_name]) { @content }.
            render(nil, get_variables(variables))
        has_cr = content.index("\r")
        content += (has_cr ? "\r\n" : "\n") if content[-1] != "\n"
        if @parent.nil?
          content
        else
          @parent.render({'content' => content})
        end
      end

      # @!attribute [r] input_path
      # @return [String] the full path to the file in the source directory
      def input_path
        File.join(content_path, @name)
      end

      # @!attribute [r] output_extension
      # @return [String] the extension to use with the output file.
      def output_extension
        case @type
          when 'erb', 'rhtml', 'erubis', 'liquid'
            nil
          when 'coffee'
            'js'
          when 'less', 'sass', 'scss'
            'css'
          else
            'html'
        end
      end

      # @!attribute [r] output_filename
      # @return [String] the filename to use in the output directory.
      #
      # Returns the filename to use for the output directory with any modifications to the input filename required.
      def output_filename
        if output_extension
          @name[0..@name.rindex('.')] + output_extension
        else
          @name[0..@name.rindex('.') - 1]
        end
      end

      # Static method to create a layout for a given configuration by it's name if it exists. This differs from
      # `#initialise` in that it allows different types of values to be supplied as the name and will not fail if name
      # is nil
      #
      # @param configuration [Usmu::Configuration] The configuration to use for the search
      # @param name [String]
      #   If name is a string then search for a template with that name. Name here should not include
      #   file extension, eg. body not body.slim. If name is not a string then it will be returned verbatim. This means
      #   that name is nilable and can also be passed in as an Usmu::Layout already for testing purposes.
      # @return [Usmu::Layout]
      def self.find_layout(configuration, name)
        if name === 'none'
          nil
        elsif name.class.name == 'String'
          Dir["#{configuration.layouts_path}/#{name}.*"].each do |f|
            filename = File.basename(f)
            if filename != "#{name}.meta.yml"
              return new(configuration, f[(configuration.layouts_path.length + 1)..f.length])
            end
          end
          nil
        else
          name
        end
      end

      # Tests if a given file is a valid Tilt template based on the filename.
      #
      # @param folder_type [String]
      #   One of `"source"` or `"layout"` depending on where the template is in the source tree.
      #   Not used by Usmu::Layout directly but intended to be available for future API.
      # @param name [String] The filename to be tested.
      # @return [Boolean]
      def self.is_valid_file?(folder_type, name)
        type = name.split('.').last
        ::Tilt.default_mapping[type] ? true : false
      end

      protected

      # @!attribute [r] template_class
      # @return [Tilt::Template] the Tilt template engine for this layout
      def template_class
        @template_class ||= ::Tilt.default_mapping[@type]
      end

      # @!attribute [r] provider_name
      # @return [String] the Tilt template engine's name for this layout
      #
      # Returns the Tilt template engine's name for this layout.
      #
      # This is used to determine which settings to use from the configuration file.
      def provider_name
        Tilt.default_mapping.lazy_map[@type].select {|x| x[0] == template_class.name }.first[1].split('/').last
      end

      # @!attribute [r] content_path
      # @return [string] the base path to the files used by this class.
      #
      # Returns the base path to the files used by this class.
      #
      # This folder should be the parent folder for the file named by the name attribute.
      #
      # @see #name
      def content_path
        @configuration.layouts_path
      end

      private

      # Utility function which collates variables to pass to the template engine.
      #
      # @return [Hash]
      def get_variables(variables)
        {site: @configuration}.deep_merge!(metadata).deep_merge!(variables)
      end
    end
  end
end
