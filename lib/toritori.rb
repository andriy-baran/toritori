# frozen_string_literal: true

require 'dry/inflector'
require 'toritori/dsl'
# require 'toritori/group_definition'
require 'toritori/subclassing_helpers'
require 'toritori/inheritance_helpers'
require 'toritori/factory'
require 'toritori/module_builder'
require_relative "toritori/version"

module Toritori
  class Error < StandardError; end

# Defines high level interface
  module ClassMethods
    def factories
      @factories ||= {}
    end

    def method_missing(method_name, *args, &block)
      binding.pry
      if method_name.match?(Regexp.new("(.*)_#{factories.keys.join('|')}$"))
      if factories.key?(method_name)
        factories[method_name].call(*args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      factories.key?(method_name) || super
    end

    def factory(name, base_class = Class.new, init_methods = %i[new])
      factories[name] = Toritori::Factory.new(name, nil, base_class: base_class, init: init_methods)
    end

    def produce(*components_names, &block)
      components_names.each do |components_name|
        include ModuleBuilder.call(components_name)
      end
      # groups = GroupDefinition.new
      # groups.instance_eval(&block) if block
      # groups.definitions.each do |components_name, attrs|
      #   include ModuleBuilder.call(components_name, **attrs)
      # end
    end
  end

  def self.global_registry_module_id(components_name, base_class: nil, init: nil)
    [components_name, base_class, init].hash
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end

  def self.registered_modules
    Factories.memoized_modules
  end
end
