
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
      # @param [Array<Usmu::Template::Page>] files
      def initialize(files)
        @files = files
      end

      def previous_from(file)
        i = @files.index file
        return unless i
        @files[(i - 1) % @files.length]
      end

      def next_from(file)
        i = @files.index file
        return unless i
        @files[(i + 1) % @files.length]
      end
    end
  end
end
