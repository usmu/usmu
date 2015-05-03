
module Usmu
  class MockCommander
    def initialize
      @commands = {}
    end

    def get_command(name)
      @commands[name]
    end

    def command(name, &block)
      @current_command = name
      @commands[name] = {}

      block.yield(self)
    end

    def syntax=(value)
      @commands[@current_command][:syntax] = value
    end

    def description=(value)
      @commands[@current_command][:description] = value
    end

    def action(&block)
      @commands[@current_command][:action] = block
    end
  end
end
