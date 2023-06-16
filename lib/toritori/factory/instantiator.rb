# frozen_string_literal: true

module Toritori
  class Factory
    # Utility class that evaluates initalization procs
    class Instantiator < BasicObject
      def initialize(subclass)
        @subclass = subclass
        @type = subclass.base_class
        define_singleton_method(:__create__, &subclass.init)
      end

      def method_missing(method, *args, **kwargs, &block)
        return super unless @type.respond_to?(method)

        @type.public_send(method, *args, **kwargs, &block)
      end

      def respond_to_missing?(method, include_private = false)
        @type.respond_to?(method, include_private) || super
      end
    end
  end
end
