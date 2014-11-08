require 'tilt'
require 'deep_merge'

module Usmu
  class Layout
    def initialize(configuration, name, type = nil, content = nil, metadata = nil)
      @configuration = configuration
      @name = name

      if type.nil?
        Dir[configuration.layouts_path + "/#{name}.*"].each do |f|
          filename = File.basename(f)
          if filename != "#{name}.meta.yml"
            type = filename[(name.length + 1)..filename.length]
          end
        end

        raise "Unable to find a find a layout named #{name} in #{configuration.layouts_path}." if type.nil?
      end
      @type = type

      if content.nil?
        content = File.read(File.join(configuration.layouts_path, "#{name}.#{type}"))
      end
      @content = content

      if metadata.nil?
        meta_file = File.join(configuration.layouts_path, "#{name}.meta.yml")
        metadata = if File.exist? meta_file
          YAML.load_file(meta_file)
        else
          {}
        end
      end
      @metadata = metadata

      @parent = unless metadata['layout'].nil?
                  if metadata['layout'].class.name == 'String'
                    Usmu::Layout.new(configuration, metadata['layout'])
                  else
                    metadata['layout']
                  end
                else
                  nil
                end
    end

    def metadata
      if @parent.nil?
        @metadata.deep_merge(@configuration['default meta'] || {})
      else
        @metadata.deep_merge(@parent.metadata)
      end
    end

    def render(variables)
      content = ::Tilt.default_mapping[@type].
          new("#{@name}.#{@type}", 1, @configuration[@type]) { @content }.
          render(nil, get_variables(variables))
      if @parent.nil?
        content
      else
        @parent.render({'content' => content})
      end
    end

    private

    def get_variables(variables)
      variables.deep_merge(metadata).deep_merge({site: @configuration})
    end
  end
end
