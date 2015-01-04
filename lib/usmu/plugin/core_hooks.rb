
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
    end
  end
end
