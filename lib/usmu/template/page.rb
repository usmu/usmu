require 'usmu/template/layout'
require 'time'

module Usmu
  module Template
    # Represents a page in the source directory of the website.
    class Page < Layout

      private
      alias :super_output_filename :output_filename

      public

      # @param configuration [Usmu::Configuration] The configuration for the website we're generating.
      # @param name [String] The name of the file in the source directory.
      # @param metadata [Hash] The metadata for the file.
      # @param type [String] The type of template to use with the file. Used for testing purposes.
      # @param content [String] The content of the file. Used for testing purposes.
      def initialize(configuration, name, metadata, type = nil, content = nil)
        super(configuration, name, metadata, type, content)

        current_parent = parent
        until current_parent.nil?
          @log.debug("Injecting page #{name} into #{current_parent.name}")
          current_parent['page'] = self
          current_parent = current_parent.parent
        end
      end

      def output_filename
        permalink || super_output_filename
      end

      def date
        date = self['date']
        if date.is_a? Time
          return date
        end

        if date
          date = Time.parse(date) rescue nil
        end

        unless date
          date = File.stat(input_path).mtime
        end

        date
      end

      protected

      # @!attribute [r] content_path
      # @return [string] the base path to the files used by this class.
      #
      # Returns the base path to the files used by this class.
      #
      # This folder should be the parent folder for the file named by the name attribute.
      #
      # @see #name
      def content_path
        @configuration.source_path
      end

      def permalink
        link = self['permalink']
        return nil unless link

        date = self.date

        extension = output_extension
        extension = '.' + extension if extension

        link_tr = link.gsub('%f', File.basename(@name[0..(@name.rindex('.') - 1)]))
        date.strftime(link_tr) + extension
      end
    end
  end
end
