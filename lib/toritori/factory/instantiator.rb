module Toritori
  class Factory
    # Utility class that evaluates initalization procs
    class Instantiator < BasicObject
      def initialize(type)
        @type = type
      end

      def method_missing(method, *args, &block)
        return super unless @type.respond_to?(method)

        @type.public_send(method, *args, &block)
      end

      def respond_to_missing?(method, include_private = false)
        @type.respond_to?(method, include_private) || super
      end
    end
  end
end
