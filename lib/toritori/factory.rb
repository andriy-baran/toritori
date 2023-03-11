# frozen_string_literal: true

module Toritori
  # Generates module that adds support for objects creation
  class Factory
    attr_reader :name, :base_class, :subclass, :init

    def initialize(name, base_class: nil, init: Toritori.default_init)
      @name = name
      @base_class = base_class
      @subclass = base_class
      @init = Toritori.check_init(init)
    end

    def patch_class(&block)
      return base_class unless block

      @subclass = Class.new(base_class, &block)
    end

    def init=(new_init)
      @init = Toritori.check_init(new_init)
    end

    def create(*args, &block)
      if args.size != expected_arity
        raise(ArgumentError, "wrong number of arguments (given #{args.size}, expected #{expected_arity})")
      end

      @init.call(subclass, *args, &block)
    end

    private

    def expected_arity
      @init.arity - 1
    end
  end
end
