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
        local_files = local_files_list
        remote_files = @remote_files.files_list

        updated_files = (local_files & remote_files).select &method(:filter_files)

        {
            :local => local_files - remote_files,
            :remote => remote_files - local_files,
            :updated => updated_files,
        }
      end

      private

      attr_reader :configuration
      attr_reader :remote_files

      def filter_files(f)
        lstat = File.stat("#{@configuration.destination_path}/#{f}")
        rstat = @remote_files.stat(f)
        lhash = File.read("#{@configuration.destination_path}/#{f}")

        hash_comparison = !check_hash(lhash, rstat)
        time_comparison = lstat.mtime > rstat[:mtime]

        time_comparison || hash_comparison
      end

      def check_hash(lhash, rstat)
        if not rstat[:md5].nil?
          rhash = rstat[:md5]
          Digest::MD5.hexdigest(lhash).eql? rhash
        elsif not rstat[:sha1].nil?
          rhash = rstat[:sha1]
          Digest::SHA1.hexdigest(lhash).eql? rhash
        else
          true
        end
      end

      def local_files_list
        Dir[@configuration.destination_path + '/**/{*,.??*}'].map do |f|
          f[(@configuration.destination_path.length + 1), f.length]
        end
      end
    end
  end
end
