require 'tilt'
require 'deep_merge'
require 'usmu/template/helpers'
require 'usmu/template/static_file'

module Usmu
  module Template
    # Class to represent files templated with a Tilt library. Most of the custom rendering logic is contained here.
    class Layout < StaticFile
      @layout_history = Hash.new({})
      @log = Logging.logger[self]

      # @!attribute [r] type
      # @return [String] the type of file this is. This is used to determine which template engine to use.
      attr_reader :type

      # @param configuration [Usmu::Configuration] The configuration for the website we're generating.
      # @param name [String] The name of the file in the source directory.
      # @param metadata [Hash] The metadata for the file.
      # @param type [String] The type of template to use with the file. Used for testing purposes.
      # @param content [String] The content of the file. Used for testing purposes.
      def initialize(configuration, name, metadata, type = nil, content = nil)
        super(configuration, name, metadata, type, content)

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

        @parent = Layout.find_layout(configuration, self.metadata['layout'])

        # Don't use the parent if it would result in weirdness
        unless @parent.nil?
          @parent = nil unless
              output_extension == @parent.output_extension || output_extension.nil? || @parent.output_extension.nil?
        end
      end

      # @!attribute [r] metadata
      # @return [Hash] the metadata associated with this layout.
      #
      # Returns the metadata associated with this layout.
      #
      # This will include any metadata from parent templates and default metadata
      def metadata
        if @parent.nil?
          @configuration['default meta', default: {}].deep_merge!(@metadata)
        else
          @parent.metadata.deep_merge!(@metadata)
        end
      end

      # This is a shortcut to accessing metadata.
      #
      # @see #metadata
      def [](index)
        metadata[index]
      end

      # Renders the file with any templating language required and returns the result
      #
      # @param variables [Hash] Variables to be used in the template.
      # @return [String] The rendered file.
      def render(variables = {})
        template_config = add_template_defaults(@configuration[provider_name] || {}, provider_name)
        content = template_class.new("#{@name}", 1, template_config) { @content }.
            render(helpers, get_variables(variables))

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
      #   that name is nilable and can also be passed in as an Usmu::Template::Layout already for testing purposes.
      # @return [Usmu::Layout]
      def self.find_layout(configuration, name)
        return nil if name.nil?

        if @layout_history[configuration][name]
          @log.debug(
              'Layout loop detected. Current loaded layouts: ' +
              @layout_history[configuration].inspect
          )
          return nil
        else
          @log.debug("Loading layout '#{name}'")
          @layout_history[configuration][name] = true
        end

        ret = search_layout(configuration, name)

        @layout_history[configuration][name] = nil
        return ret
      end

      # Tests if a given file is a valid Tilt template based on the filename.
      #
      # @param folder_type [String]
      #   One of `"source"` or `"layout"` depending on where the template is in the source tree.
      #   Not used by Usmu::Template::Layout directly but intended to be available for future API.
      # @param name [String] The filename to be tested.
      # @return [Boolean]
      def self.is_valid_file?(folder_type, name)
        type = name.split('.').last
        ::Tilt.default_mapping[type] ? true : false
      end

      protected

      # @!attribute [r] parent
      # @return [Usmu::Template::Layout] The template acting as a wrapper for this template, if any
      attr_reader :parent

      # Allows for protected level direct access to the metadata store.
      #
      # @see #metadata
      def []=(index, value)
        @metadata[index] = value
      end

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

      # @!attribute [r] helpers
      # @return [Usmu::Template::Helpers] the Helpers class to use as a scope for templates
      def helpers
        @helpers ||= Usmu::Template::Helpers.new(@configuration)
      end

      # Adds defaults for the given generator engine
      #
      # @param [Hash] overrides A hash of options provided by the user
      # @param [String] engine The name of the rendering engine
      # @return [Hash] Template options to pass into the engine
      def add_template_defaults(overrides, engine)
        case engine
          when 'sass'
            {
                :load_paths => [@configuration.source_path + '/' + File.dirname(@name)]
            }.deep_merge!(overrides)
          else
            overrides
        end
      end

      private

      # Utility function which collates variables to pass to the template engine.
      #
      # @return [Hash]
      def get_variables(variables)
        {'site' => @configuration}.deep_merge!(metadata).deep_merge!(variables)
      end

      # @see Usmu::Template::Layout#find_layout
      # @return [Usmu::Template::Layout]
      def self.search_layout(configuration, name)
        if name === 'none' || name.nil?
          return nil
        elsif name.class.name == 'String'
          layouts_path = configuration.layouts_path
          Dir["#{layouts_path}/#{name}.*"].each do |f|
            filename = File.basename(f)
            if filename != "#{name}.meta.yml"
              path = f[(layouts_path.length + 1)..f.length]
              return new(configuration, path, configuration.layouts_metadata.metadata(path))
            end
          end
        else
          return name
        end
      end
    end
  end
end
