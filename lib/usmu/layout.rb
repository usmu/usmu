require 'tilt'
require 'deep_merge'
require 'usmu/static_file'

module Usmu
  class Layout < StaticFile
    attr_reader :type

    def initialize(configuration, name, type = nil, content = nil, metadata = nil)
      super(configuration, name)

      if type.nil?
        type = name.split('.').last
        raise "Templates of type '#{type}' aren't recognised by Tilt." unless ::Tilt.default_mapping[type]
      end
      @type = type
      path = File.join("#{content_path}", "#{name[0, name.length - type.length - 1]}")

      if content.nil?
        p "#{path}.#{type}"
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

      @parent = if metadata['layout'].nil?
                  nil
                else
                  if metadata['layout'].class.name == 'String'
                    Layout.find_layout(configuration, metadata['layout'])
                  else
                    metadata['layout']
                  end
                end
    end

    def metadata
      if @parent.nil?
        @metadata.deep_merge(@configuration['default meta'] || {})
      else
        @metadata.deep_merge(@parent.metadata)
      end
    end

    def render(variables = {})
      template_class = ::Tilt.default_mapping[@type]
      provider = Tilt.default_mapping.lazy_map[@type].select {|x| x[0] == template_class.name }.first[1].split('/').last

      content = template_class.new("#{@name}.#{@type}", 1, @configuration[provider]) { @content }.
          render(nil, get_variables(variables))
      has_cr = content.index("\r")
      content += (has_cr ? "\r\n" : "\n") if content[-1] != "\n"
      if @parent.nil?
        content
      else
        @parent.render({'content' => content})
      end
    end

    def self.find_layout(configuration, name)
      Dir["#{configuration.layouts_path}/#{name}.*"].each do |f|
        filename = File.basename(f)
        if filename != "#{name}.meta.yml"
          return new(configuration, f[(configuration.layouts_path.length + 1)..f.length])
        end
      end
    end

    protected

    def content_path
      @configuration.layouts_path
    end

    private

    def get_variables(variables)
      variables.deep_merge(metadata).deep_merge({site: @configuration})
    end
  end
end
