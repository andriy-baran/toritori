# frozen_string_literal: true

module Toritori
  class Factory
    # Utility class that stores initalization procs
    class Subclass < BasicObject
      attr_accessor :creation_method

      def initialize(base_class)
        @base_class = base_class
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
