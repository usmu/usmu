require 'usmu/deployment/remote_file_interface'

module Usmu
  class MockRemoteFiles
    include Usmu::Deployment::RemoteFileInterface

    def initialize(files)
      @files = files
    end

    def files_list
      @files.keys
    end

    def stat(filename)
      @files[filename]
    end
  end
end
