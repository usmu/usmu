
module Usmu
  class Plugin
    def initialize
      @log = Logging.logger['Usmu::Plugin']
    end

    # Loads all plugins that are available as gems. This is determined by looking at the gem's name. Anything prefixed
    # with the string 'usmu-' will be recognised as a plugin. This will load the gem according to the RubyGems
    # recommendations for naming schemes. A gem named `usmu-s3_uploader` will be loaded by requiring the path
    # `'usmu/s3_uploader'` and then then the class `Usmu::S3Uploader` will be instantiated as the plugins interface.
    #
    # @return [void]
    def load_plugins
      loaded = []
      @log.debug('Loading plugins')
      @log.debug('Loaded Usmu::Plugin::Core')
      plugins.push Usmu::Plugin::Core.new
      Gem::Specification.find_all { |s| s.name =~ /^usmu-/ }.each do |spec|
        load_path = spec.name.gsub('-', '/')
        require load_path

        unless loaded.include? load_path
          loaded << load_path
          klass = load_path.split('/').map {|s| s.split('_').map(&:capitalize).join }.join('::')
          @log.debug("Loading plugin #{klass} from '#{load_path}'")
          plugins.push plugin_get(klass)
        end
      end
      @log.debug("Loaded: #{plugins.inspect}")
    end

    # @!attribute [r] plugins
    # @return [Array] a list of all plugins discovered and loaded.
    def plugins
      @plugins ||= []
    end

    # Call all plugins and collate any data returned. nil can be returned explicitly to say this plugin has nothing to
    # return.
    # @param [Symbol] method The name of the method to call. This should be namespaced somehow. For example, a plugin
    #                        called `usmu-s3` could use the method namespace `s3` and have a hook called `:s3_upload`
    # @param [Array] args The arguments to pass through to plugins. Can be empty.
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

    private

    def plugin_get(klass)
      object.const_get(klass).new
    rescue NameError
      # Ruby 1.9.3, dowp
      klass.split('::').reduce(Object) {|memo, o| memo.const_get o }.new
    end
  end
end
