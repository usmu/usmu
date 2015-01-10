require 'digest'

module Usmu
  module Deployment
    class DirectoryDiff
      # @param [Usmu::Configuration] configuration
      # @param [Usmu::Deployment::RemoteFileInterface] remote_files
      def initialize(configuration, remote_files)
        @configuration = configuration
        @remote_files = remote_files
      end

      # @return [Hash]
      #   A hash of arrays of filenames:
      #
      #   * `:local` - local-only files
      #   * `:remote` - remote-only files
      #   * `:updated` - files that were updated
      def get_diffs
        local_files = Dir[@configuration.destination_path + '/**/{*,.??*}'].map do |f|
          f[(@configuration.destination_path.length + 1)..f.length]
        end
        remote_files = @remote_files.files_list

        updated_files = (local_files & remote_files).select do |f|
          lstat = File.stat("#{@configuration.destination_path}/#{f}")
          rstat = @remote_files.stat(f)
          lhash = File.read("#{@configuration.destination_path}/#{f}")

          if not rstat[:md5].nil?
            rhash = rstat[:md5]
            hash_comparison = Digest::MD5.hexdigest(lhash) != rhash
          elsif not rstat[:sha1].nil?
            rhash = rstat[:sha1]
            hash_comparison = Digest::SHA1.hexdigest(lhash) != rhash
          else
            hash_comparison = false
          end

          time_comparison = lstat.mtime > rstat[:mtime]

          p f
          p time_comparison
          p hash_comparison
          time_comparison || hash_comparison
        end

        {
            :local => local_files - remote_files,
            :remote => remote_files - local_files,
            :updated => updated_files,
        }
      end
    end
  end
end
