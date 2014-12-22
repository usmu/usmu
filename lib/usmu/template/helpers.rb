# We really should include this, but it causes an include loop and Include has a strict dependency on Layout due to
# the inheritance structure. Oh well. Perhaps I'll think of something later.
#require 'usmu/template/include'

module Usmu
  module Template
    class Helpers
      def initialize(configuration)
        @configuration = configuration
      end

      def include(name, args = {})
        inc = Usmu::Template::Include.find_include(@configuration, name)
        inc.arguments = args
        inc.render
      end
    end
  end
end
