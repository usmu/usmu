
module Usmu
  class StaticFile
    attr_reader :name

    def initialize(configuration, name, type = nil, content = nil, metadata = nil)
      @configuration = configuration
      @name = name
      @type = type
      @content = content
    end

    def render(variables = {})
      @content || File.read(File.join(@configuration.source_path, @name))
    end
  end
end
