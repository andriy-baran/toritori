# frozen_string_literal: true

module Toritori
  # Generates module that adds support for objects creation
  class Factory
    attr_reader :name

    def copy
      self.class.new(name, base_class: base_class, creation_method: @subclass.creation_method)
    end

    def initialize(name, base_class: nil, creation_method: :new)
      @name = name
      @subclass = Subclass.new(base_class, creation_method)
    end

    def subclass(produces: nil, creation_method: @subclass.creation_method, &block)
      child_class = produces || base_class
      child_class = Class.new(child_class, &block) if block
      @subclass = Subclass.new(child_class, creation_method)
    end

    def create(*args, **kwargs, &block)
      base_class.public_send(creation_method, *args, **kwargs, &block)
    end

    def base_class
      @subclass.base_class
    end

    def creation_method
      @subclass.creation_method
    end
  end
end
