
module Usmu
  # Singletonish class to load plugins and act as an interface to them. Shouldn't be created directly.
  # @see Usmu.plugins
  class Plugin
    # Constructor for the plugin interface.
    def initialize
      @log = Logging.logger['Usmu::Plugin']
    end

    # Loads all plugins that are available as gems. This is determined by looking at the gem's name. Anything prefixed
    # with the string 'usmu-' will be recognised as a plugin. This will load the gem according to the RubyGems
    # recommendations for naming schemes. A gem named `usmu-s3_uploader` will be loaded by requiring the path
    # `'usmu/s3_uploader'` and then then the class `Usmu::S3Uploader` will be instantiated as the plugins interface.
    def load_plugins
      @loaded = []
      @log.debug('Loading plugins')
      @log.debug('Loaded Usmu::Plugin::Core')
      plugins.push Usmu::Plugin::Core.new
      Gem::Specification.find_all { |s| s.name =~ /^usmu-/ }.each &method(:load_gem)
      @log.debug("Loaded: #{plugins.inspect}")
    end

    # @!attribute [r] plugins
    # @return [Array] a list of all plugins discovered and loaded.
    def plugins
      @plugins ||= []
    end

    def [](klass)
      plugins.select {|s| s.class == klass }.first
    end

    # Call all plugins and collate any data returned.
    #
    # nil can be returned explicitly to say this plugin has nothing to return.
    #
    # @param [Symbol] method The name of the method to call. This should be namespaced somehow. For example, a plugin
    #                        called `usmu-s3` could use the method namespace `s3` and have a hook called `:s3_upload`
    # @param [Array] args The arguments to pass through to plugins. Can be empty.
    # @return [Array] An array of non-nil values returned from plugins
    def invoke(method, *args)
      @log.debug("Invoking plugin API #{method}")
      plugins.map do |p|
        if p.respond_to? method
          @log.debug("Sending message to #{p.class.name}")
          p.public_send method, *args
        else
          nil
        end
      end.select {|i| i}
    end

    # Call all plugins and allow for altering a value.
    #
    # The return value of each hook is passed into the next alter function, hence all implementations must always
    # return a value. If the hook doesn't wish to modify data this call then it should return the original value.
    #
    # @param [Symbol] method The name of the method to call. This should be namespaced somehow. For example, a plugin
    #                        called `usmu-s3` could use the method namespace `s3` and have a hook called `:s3_upload`
    # @param [Object] value The value to modify.
    # @param [Array]  context Optional extra parameters to provide.
    # @return [Object] The modified value.
    def alter(method, value, *context)
      @log.debug("Invoking plugin alter API #{method}")
      plugins.each do |p|
        if p.respond_to? "#{method}_alter"
          @log.debug("Sending message to #{p.class.name}")
          value = p.public_send "#{method}_alter", value, *context
        end
      end
      value
    end

    private

    # Helper function to load and instantiate plugin classes
    #
    # @param [String] klass The name of the class to load
    # @return [Object] A plugin object
    def plugin_get(klass)
      Object.const_get(klass).new
    end

    # Helper function to load a plugin from a gem specification
    #
    # @param [Gem::Specification] spec
    def load_gem(spec)
      load_path = spec.name.gsub('-', '/')
      require load_path

      unless @loaded.include? load_path
        @loaded << load_path
        klass = path_to_class(load_path)
        @log.debug("Loading plugin #{klass} from '#{load_path}'")
        plugins.push plugin_get(klass)
      end
      nil
    end

    def path_to_class(load_path)
      load_path.split('/').map { |s| s.split('_').map(&:capitalize).join }.join('::')
    end
  end
end
