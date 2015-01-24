
module Usmu
  class MockMetadataConfiguration
    def initialize(hash)
      @config = hash
    end

    def metadata(filename)
      @config[filename] || {}
    end
  end
end
