# frozen_string_literal: true

module Toritori
  # Copies configuration to subclass
  module InheritanceHelpers
    def inherited(subclass)
      super
      subclass.copy_superclass_configuration
    end

    def copy_superclass_configuration
      toritori_included_modules.each do |factory|
        toritori_copy_configuration_for_unit(factory.component_name)
        toritori_activate_components_for_factory(factory)
      end
    end

    def toritori_included_modules
      included_modules.select { |mod| mod.is_a?(Toritori::ModuleBuilder) }
    end

    def toritori_copy_configuration_for_unit(component_name)
      readers_regexp = Regexp.new("\\w+_#{component_name}_class\\z")
      superclass.public_methods.grep(readers_regexp).each do |reader_method|
        klass = superclass.public_send(reader_method)
        public_send(:"#{reader_method}=", klass)
      end
    end

    def toritori_activate_components_for_factory(factory)
      superclass.public_send(factory.components_storage_name.to_s).each do |component, klass|
        public_send(factory.class_writter_method_name(component), klass)
      end
    end
  end
end
