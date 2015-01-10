
module Usmu
  # This module is a namespace for all common deployment related classes. This includes some helpers for deployment
  # plugins such as the S3 plugin.
  module Deployment
  end
end

%w{
  usmu/deployment/directory_diff
  usmu/deployment/remote_file_interface
}.each {|f| require f }
