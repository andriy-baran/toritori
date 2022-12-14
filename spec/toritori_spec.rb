# frozen_string_literal: true

require 'ostruct'
require 'json'

class Parser
  def call; end
end

RSpec.describe Toritori do
  vars do
    other_class! do
      Class.new do
        include Toritori
        produces :components
      end
    end
    operation_class do
      Class.new do
        include Toritori
        produces :controllers

        def initialize(formatter)
          @formatter = formatter
        end

        controller :parser, base_class: Parser
        controller :formatter

        parser_controller do
          def parse(json)
            JSON.parse(json, symbolize_names: true)
          end
        end

        formatter_controller do
          attr_reader :id, :app

          def initialize(opts = {})
            @id = opts[:id]
            @app = opts[:app]
          end

          def call
            { id: id, success: true, app: app }
          end
        end

        def self.test_instance(json)
          parser = new_parser_controller_instance
          formatter = new_formatter_controller_instance(parser.parse(json))
          new(formatter)
        end

        def call
          @formatter.call
        end
      end
    end
    value { { id: 3, app: 'RSpec' } }
  end

  it { expect(operation_class).to respond_to(:controller) }
  it { expect(operation_class).to respond_to(:parser_controller_class) }
  it { expect(operation_class).to respond_to(:formatter_controller_class) }
  it { expect(operation_class).to respond_to(:new_parser_controller_instance) }
  it { expect(operation_class).to respond_to(:new_formatter_controller_instance) }

  describe 'components instances' do
    it 'generates new instances based in init block' do
      expect(operation_class.new_parser_controller_instance).to be_a operation_class.parser_controller_class
      expect(operation_class.new_formatter_controller_instance).to be_a operation_class.formatter_controller_class
      expect(operation_class.new_formatter_controller_instance(app: 'RSpec').app).to eq 'RSpec'
    end
  end

  describe '#call' do
    it 'when everything is ok' do
      operation = operation_class.test_instance(JSON.dump(value))
      expect(operation.call).to eq(value.merge(success: true))
    end
  end

  context 'when class provided, but not a subclass of SteelWheel::Action' do
    it 'raises ArgumentError' do
      parser_class = Class.new
      expect do
        operation_class.parser_controller_class = parser_class
      end.to raise_error(ArgumentError, "must be a subclass of #{operation_class.parser_controller_class}")
    end
  end

  describe 'inheritance' do
    vars do
      child_operation_class do
        Class.new(operation_class) do
          formatter_controller do
            def call
              { id: id, child: true, app: app }
            end
          end
        end
      end
    end

    it { expect(child_operation_class).to respond_to(:parser_controller_class) }
    it { expect(child_operation_class).to respond_to(:formatter_controller_class) }

    it 'overrides components' do
      operation = child_operation_class.test_instance(JSON.dump(value))
      expect(operation.call).to eq(value.merge(child: true))
    end
  end

  describe 'double inheritance' do
    vars do
      child_operation_class do
        Class.new(operation_class) do
          formatter_controller do
            def call
              { id: id, child: true, app: app }
            end
          end
        end
      end
      child_of_child_operation_class do
        Class.new(child_operation_class)
      end
    end

    it { expect(child_of_child_operation_class).to respond_to(:parser_controller_class) }
    it { expect(child_of_child_operation_class).to respond_to(:formatter_controller_class) }

    it 'overrides components' do
      operation = child_of_child_operation_class.test_instance(JSON.dump(value))
      expect(operation.call).to eq(value.merge(child: true))
    end
  end

  describe 'base class overriding' do
    vars do
      child_operation_class do
        Class.new(operation_class) do
          controller :formatter, base_class: Class.new(OpenStruct) {
                                               def format
                                                 'json'
                                               end
                                             }
          def format
            @formatter.format
          end
        end
      end
    end

    it 'overrides base class' do
      operation = child_operation_class.test_instance(JSON.dump(value))
      expect(operation.format).to eq('json')
      expect(operation.call).to eq(OpenStruct.new.call)
    end
  end
end
