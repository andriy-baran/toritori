# frozen_string_literal: true

module Toritori
  # Core logic for creating objects
  module DSL
    def define_component_store_method(receiver, title)
      mod = self
      receiver.define_singleton_method(mod.class_writter_method_name(title)) do |klass| # def self.name_component=(klass)
        base_class = public_send(:"#{mod.components_storage_name}")[title]      #   base_class = public_send(:toritori_components)[title]
        toritori_check_inheritance!(klass, base_class)                          #   toritori_check_inheritance!(klass, base_class)
        send(mod.simple_store_method_name(title), klass)                        #   send(simple_store_name_component_class, klass)
      end                                                                       # end
    end

    def define_component_simple_store_method(receiver, title)
      mod = self
      receiver.define_singleton_method(mod.simple_store_method_name(title)) do |klass| # def self.simple_store_name_component_class(klass)
        send(mod.private_class_writter_method_name(title), klass)                      #   send(:write_name_component_class, klass)
        public_send(:"#{mod.components_storage_name}")[title] = klass                  #   public_send(:toritori_components)[title] = klass
      end                                                                              # end
      receiver.private_class_method mod.simple_store_method_name(title)
    end

    def define_component_activation_method
      mod = self
      define_method(mod.activation_method_name) do |title, base_class, klass, init = nil, &block| # def activate_name_component(title, base_class, klass, init = nil, &block)
        raise(ArgumentError, 'please provide a block or class') if klass.nil? && block.nil?       #   raise(ArgumentError, 'please provide a block or class') if klass.nil? && block.nil?

        toritori_check_inheritance!(klass, base_class)                                            #   toritori_check_inheritance!(klass, base_class)
        target_class = klass || base_class                                                        #   target_class = klass || base_class
        patched_class = toritori_patch_class(target_class, &block)                                #   patched_class = toritori_patch_class(target_class, &block)
        public_send(mod.class_writter_method_name(title), patched_class)                          #   public_send(:name_component=, patched_class)
      end                                                                                         # end
    end

    def define_component_new_instance_method(title)
      mod = self
      define_method mod.new_instance_method_name(title) do |*args| # def new_name_component_instance(*args)
        klass = public_send(mod.component_class_reader(title))     #   klass = public_send(:name_component_class)
        klass.__send__(mod.default_init, *args)                    #   klass.__send__(:new, *args)
      end                                                          # end
    end

    def define_component_configure_method(title)
      mod = self
      define_method mod.configure_component_method_name(title) do |klass = nil, init: nil, &block| # def name_component(klass = nil, init: nil, &block)
        base_class = public_send(:"#{mod.component_class_reader(title)}")                          #   base_class = public_send(:name_component_class)
        public_send(mod.activation_method_name, title, base_class, klass, init, &block)            #   public_send(:activate_name_component, title, base_class, klass, init, &block)
      end                                                                                          # end
      private mod.configure_component_method_name(title)
    end

    def define_component_adding_method
      mod = self
      define_method(component_name) do |title, base_class: nil, init: nil| # def component(name, base_class: nil, init: nil)
        singleton_class.class_eval do
          reader_name = mod.component_class_reader(title)                  # reader_name = :name_component_class
          attr_accessor reader_name                                        # attr_accessor :name_component_class
          alias_method :"write_#{reader_name}", :"#{reader_name}="         # alias_method :write_name_component_class, :name_component_class=
          private :"write_#{reader_name}"                                  # private :write_name_component_class
        end
        klass = base_class || mod.default_base_class || Class.new(Object)
        # Toritori::Expandable.new(title, mod.component_name, klass, init)
        mod.define_component_store_method(self, title)
        mod.define_component_simple_store_method(self, title)
        send(mod.simple_store_method_name(title), klass)
        mod.define_component_configure_method(title)
        mod.define_component_new_instance_method(title)
      end
    end

    def define_components_registry
      mod = self
      module_eval <<-METHOD, __FILE__, __LINE__ + 1
	      def #{mod.components_storage_name}       # def parts
	        @#{mod.components_storage_name} ||= {} #   @parts ||= {}
	      end                                      # end
      METHOD
    end
  end
end
