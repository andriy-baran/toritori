# frozen_string_literal: true

module Toritori
  # Generates module that adds support for objects creation
  class Factory
    attr_reader :name, :component_name, :base_class, :init, :block

    def initialize(name, component_name, base_class: nil, init: nil)
      @name = name
      @component_name = component_name
      @base_class = base_class
      @init = init
    end

    def patch_component(&block)
      return base_class unless block

      @base_class = Class.new(base_class, &block)
    end

    def new_instance(init, *args, &block)
      base_class.__send__(init, *args, &block)
    end
  end
end