require 'yaml'
require 'deep_merge'

module Usmu
  class MetadataService
    def initialize(folder)
      @base = folder
    end

    def metadata(file)
      last_folder = file.rindex('/')
      base_meta = last_folder ? metadata(file[0..(last_folder - 1)]) : {}

      metafile = if File.directory?(File.join(@base, file))
                   file + '/meta.yml'
                 else
                   dot_position = File.basename(file).rindex('.')
                   if (!dot_position.nil?) && dot_position > 0
                     file[0, file.rindex('.')] + '.meta.yml'
                   else
                     file + '.meta.yml'
                   end
                 end

      metafile = File.join(@base, metafile)
      if File.exist? metafile
        base_meta.deep_merge! YAML.load_file(metafile)
      else
        base_meta
      end
    end

    private

    attr_reader :base
  end
end
