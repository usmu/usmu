
module Usmu
  module Helpers
    module Indexer
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def indexer(variable)
          # An index accessor to directly access the configuration file. It should be noted that `['source']` and
          # `#source_path` and other similar pairs will have different values. `['source']` is the raw value from the
          # configuration file while the latter is a path on the system, potentially altered by the path from the current
          # working directory to the configuration file and other factors. The accessor functions such as `#source_path`
          # should be preferred for most usages.
          #
          # @param [String, Symbol] indices
          #   A list of indices to use to find the value to return. Can also include an options hash with the
          #   following options:
          #
          #   * `:default`: Sets the default value if the value can't be found.
          #
          # @return [Array, Hash, String, Symbol]
          #   Returns a value from the hash loaded from YAML. The type of value will ultimately depend on the configuration
          #   file and the indices provided.
          define_method(:[]) do |*indices|
            if indices.last.instance_of? Hash
              opts = indices.pop
            else
              opts = {}
            end

            value = variable.to_s[0] == '@' ? instance_variable_get(variable) : send(variable)
            while indices.length > 0
              i = indices.shift
              if value.key? i
                value = value[i]
              else
                return opts[:default]
              end
            end

            value
          end
        end
      end
    end
  end
end
