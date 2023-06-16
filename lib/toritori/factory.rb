# frozen_string_literal: true

module Toritori
  # Generates module that adds support for objects creation
  class Factory
    attr_reader :name

    def cached_instantiator(subclass)
      id = [subclass.base_class.object_id, subclass.init.object_id].join('_')
      @cache ||= ::Hash.new do |h, key|
        h[key] = Instantiator.new(subclass)
      end
      @cache[id]
    end

    def copy
      self.class.new(name, base_class: base_class, &subclass.init)
    end

    def initialize(name, base_class: nil, &block)
      @name = name
      @subclass = Subclass.new(base_class, block)
    end

    def subclass(&block)
      return @subclass unless block

      @subclass = Subclass.new(Class.new(base_class, &block), @subclass.init)
    end

    def create(*args, **kwargs, &block)
      cached_instantiator(@subclass).__create__(*args, **kwargs, &block)
    end

    def base_class
      @subclass.base_class
    end
  end
end
