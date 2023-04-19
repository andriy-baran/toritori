module Toritori
  class Factory
    # Utility class that evaluates initalization procs
    class Subclass < BasicObject
      def initialize
        @init = ::Toritori.default_init
      end

      def init(&block)
        return @init unless block

        @init = block
      end
    end
  end
end
