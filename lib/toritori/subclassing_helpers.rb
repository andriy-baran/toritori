# frozen_string_literal: true

module Toritori
  # Component-level logic for patching base classes
  module SubclassingHelpers
    def toritori_patch_class(base_class, &block)
      return base_class unless block

      Class.new(base_class, &block)
    end

    def toritori_check_inheritance!(component_class, base_class)
      return if component_class.nil? || base_class.nil?
      raise(ArgumentError, "must be a subclass of #{base_class.inspect}") unless component_class <= base_class
    end
  end
end
