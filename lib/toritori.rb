# frozen_string_literal: true

require 'toritori/factory'
require 'toritori/version'

# Main namespace
module Toritori
  class Error < StandardError; end
  class SubclassError < Error; end
  class NotAClassError < Error; end

  # Defines high level interface
  module ClassMethods
    def factories
      @factories ||= {}
    end

    def factories=(other)
      @factories = other
    end

    def factory(name, produces: Class.new, creation_method: :new, &block)
      factories[name] = Toritori::Factory.new(name, base_class: produces, creation_method: creation_method, &block)
      define_singleton_method(:"#{name}_factory") { factories[name] }
    end

    def inherited(subclass)
      super
      subclass.factories = factories.transform_values(&:copy)
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end
end
