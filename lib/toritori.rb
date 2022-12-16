# frozen_string_literal: true

require "toritori/factory"
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
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
