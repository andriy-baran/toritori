# frozen_string_literal: true

require "toritori/factory"
require "toritori/wrap"
require "toritori/version"

# Main namespace
module Toritori
  class Error < StandardError; end

  # Defines high level interface
  module ClassMethods
    def factories
      @factories ||= {}
    end

    def produces(name, base_class = Class.new, init_methods = ->(k) { k.new })
      factories[name] = Toritori::Factory.new(name, base_class: base_class, init: init_methods)
      define_singleton_method(:"#{name}_factory") { factories[name] }
    end

    def default_init
      @default_init ||= ->(k) { k.new }
    end
  end

  def self.check_init(init)
    raise(ArgumentError, 'init must be a lambda') unless init.is_a?(Proc)
    raise(ArgumentError, 'init must be a lambda') unless init.lambda?
    raise(ArgumentError, 'init lambda must have at least one required argument') if init.arity < 1

    init
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
