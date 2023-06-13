# frozen_string_literal: true

require 'toritori/factory/instantiator'
require 'toritori/factory/subclass'
require 'toritori/factory'
require 'toritori/version'

# Main namespace
module Toritori
  class Error < StandardError; end

  # Defines high level interface
  module ClassMethods
    def factories
      @factories ||= {}
    end

    def factories=(other)
      @factories = other
    end

    def factory(name, produces: Class.new, &block)
      factories[name] = Toritori::Factory.new(name, base_class: produces, &block)
      define_singleton_method(:"#{name}_factory") { factories[name] }
    end

    def inherited(subclass)
      super
      subclass.factories = factories.transform_values(&:copy)
    end
  end

  def self.default_init
    @default_init ||= ->(*args, **kwargs, &block) { new(*args, **kwargs, &block) }
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
