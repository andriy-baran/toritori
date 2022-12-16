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

    def method_missing(method_name, *args, &block)
      name_str = method_name.to_s
      factory_id = name_str.sub("_factory", "").to_sym
      if name_str.end_with?("_factory") && factories.key?(factory_id)
        factories[factory_id]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      (method_name.to_s.end_with?("_factory") && factories.key?(method_name).to_s.sub("_factory", "").to_sym) ||
        factories.key?(method_name) || super
    end

    def produces(name, base_class = Class.new, init_methods = ->(k) { k.new })
      factories[name] = Toritori::Factory.new(name, base_class: base_class, init: init_methods)
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
