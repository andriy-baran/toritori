# frozen_string_literal: true

module Toritori
  # Generates module that adds support for objects creation
  class Factory
    def copy
      self.class.new(@name, base_class: @base_class, creation_method: @creation_method)
    end

    def initialize(name, base_class: nil, creation_method: :new)
      @name = name
      @base_class = base_class
      @creation_method = creation_method
    end

    def subclass(produces: nil, creation_method: @creation_method, &block)
      @base_class = check_base_class(produces) || @base_class
      @base_class = Class.new(@base_class, &block) if block
      @creation_method = creation_method
    end

    def create(*args, **kwargs, &block)
      return @base_class.new(*args, **kwargs, &block) if @creation_method == :new

      @base_class.public_send(@creation_method, *args, **kwargs, &block)
    end

    private

    def check_base_class(subclass_const = nil)
      return unless subclass_const

      ::Kernel.raise NotAClassError unless subclass_const.is_a?(::Class)

      ::Kernel.raise(SubclassError, "must be a subclass of #{@base_class.inspect}") unless subclass_const <= @base_class

      subclass_const
    end
  end
end
