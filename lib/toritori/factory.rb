# frozen_string_literal: true

module Toritori
  # Generates module that adds support for objects creation
  class Factory
    attr_reader :name, :base_class

    def initialize(name, base_class: nil, &block)
      @name = name
      @base_class = base_class
      @subclass = Subclass.new
      @subclass.init(&block)
      instantiator_for(base_class)
    end

    def subclass(&block)
      return @subclass unless block

      sub_class = Class.new(base_class, &block)
      instantiator_for(sub_class)
    end

    def create(*args, &block)
      @instantiator.__create__(*args, &block)
    end

    private

    def instantiator_for(klass)
      @instantiator = Instantiator.new(klass)
      @instantiator.define_singleton_method(:__create__, &@subclass.init)
    end
  end
end
