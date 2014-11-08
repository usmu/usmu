
module Usmu
  class Page < Layout


    protected

    def content_path
      @configuration.source_path
    end
  end
end
