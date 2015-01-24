
module Usmu
  class Collections
    # @param [Usmu::SiteGenerator] generator
    def initialize(generator)
      @generator = generator
      refresh
    end

    def [](index)
      unless @collections[index]
        files = @generator.renderables.select {|r| r['collection'] == index }.sort_by &:date
        @collections[index] = Collection.new(files)
      end

      @collections[index]
    end

    def refresh
      @collections = {}
    end

    class Collection
      # @param [Array<Usmu::Template::Page>] pages
      def initialize(pages)
        @pages = pages
      end

      def pages
        @pages.dup
      end

      def each(&block)
        pages.each &block
      end

      def previous_from(file)
        i = @pages.index file
        return unless i
        @pages[(i - 1) % @pages.length]
      end

      def next_from(file)
        i = @pages.index file
        return unless i
        @pages[(i + 1) % @pages.length]
      end
    end
  end
end
