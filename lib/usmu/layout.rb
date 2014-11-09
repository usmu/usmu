require 'tilt'
require 'deep_merge'

module Usmu
  class Layout
    attr_reader :name
    attr_reader :type

    def initialize(configuration, name, type = nil, content = nil, metadata = nil)
      @configuration = configuration
      @name = name
      path = File.join("#{content_path}", "#{name}")

      if type.nil?
        Dir["#{path}.*"].each do |f|
          filename = File.basename(f)
          if filename != "#{name}.meta.yml"
            type = filename[(name.length + 1)..filename.length]
          end
        end

        raise "Unable to find a find a #{self.class.name.split('::').last.downcase} named #{name} in #{content_path}." if type.nil?
      end
      @type = type

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
