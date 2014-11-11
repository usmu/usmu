%W{
  usmu/version
  usmu/configuration
  usmu/static_file
  usmu/layout
  usmu/page
  usmu/site_generator
}.each { |f| require f }

# This module contains all the code for the Usmu site generator
module Usmu
end
