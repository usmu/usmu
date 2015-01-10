
module Usmu
  module Deployment
    module RemoteFileInterface
      # Returns a complete list of files on the remote server.
      #
      # @return [Array<String>] An array of filenames including paths.
      def files_list
        raise NotImplementedError
      end

      # Returns a hash of information about the named file, including at a minimum the following:
      #
      # * `:mtime` - DateTime representing when the file was last modified.
      # * One of `:md5` or `:sha1` - A hash of the remote file.
      #
      # @param [String] filename The full path and filename as returned from #files_list.
      #
      # @return [Hash]
      def stat(filename)
        raise NotImplementedError
      end
    end
  end
end
