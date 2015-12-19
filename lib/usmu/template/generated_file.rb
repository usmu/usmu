require 'usmu/template/static_file'

module Usmu
  module Template
    class GeneratedFile < StaticFile
      def initialize(configuration, name, metadata = {}, type = nil, content = nil)
        super(configuration, name, metadata, type, content)
      end

      def render
        unless @content
          raise 'Render not implemented'
        end
        @content
      end

      def input_path
        nil
      end

      def metadata
        @metadata
      end

      def inspect
        "\#<#{self.class}:#{'0x%08x' % __id__} #{@name} => #{output_filename}>"
      end
    end
  end
end
