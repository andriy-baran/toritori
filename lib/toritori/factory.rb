# frozen_string_literal: true

module Toritori
  # Generates module that adds support for objects creation
  class Factory
    attr_reader :name, :base_class, :subclass, :init

    def initialize(name, base_class: nil, init: nil)
      @name = name
      @base_class = base_class
      @subclass = base_class
      @init = init
    end

    def patch_class(&block)
      return base_class unless block

      @subclass = Class.new(base_class, &block)
    end

    def create(*args, &block)
      @init.call(subclass, *args, &block)
    end
  end
end
