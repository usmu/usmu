
module Usmu
  class Plugin
    # This class describes all the hooks available from Usmu Core.
    # @api hooks
    class CoreHooks
      # Hook to allow adding commands to the console UI.
      #
      # @param [Usmu::Ui::Console] ui The UI instance for this session.
      # @param [Commander::Runner] c The Commander instance to add commands to.
      def commands(ui, c); end

      # Hook to allow altering the list of files that are in the site.
      #
      # @param [Array<Usmu::Template::StaticFile>] renderables An array of renderables.
      # @param [Usmu::SiteGenerator] generator The site generator being used.
      #
      # @return [Array<Usmu::Template::StaticFile>] The altered list of renderables.
      def renderables_alter(renderables, generator); end
    end
  end
end
