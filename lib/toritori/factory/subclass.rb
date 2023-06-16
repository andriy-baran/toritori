# frozen_string_literal: true

module Toritori
  class Factory
    # Utility class that stores initalization procs
    class Subclass < BasicObject
      def initialize(base_class, init)
        @init = init || ::Toritori.default_init
        @base_class = base_class
      end

      def init(&block)
        return @init unless block

        @init = block
      end

      def base_class(subclass_const = nil)
        return @base_class unless subclass_const

        ::Kernel.raise NotAClassError unless subclass_const.is_a?(::Class)
        unless subclass_const <= @base_class
          ::Kernel.raise(SubclassError, "must be a subclass of #{@base_class.inspect}")
        end

        @base_class = subclass_const
      end
    end
  end
end
