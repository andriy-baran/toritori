# frozen_string_literal: true

class EasyParams
  def self.create(*args, **kwargs, &block)
    new(*args, **kwargs, &block)
  end

  def initialize(data)
    @data = data
  end

  def get
    @data + 5
  end
end

RSpec.describe Toritori do
  vars do
    abstract_factory do
      Class.new do
        include Toritori

        factory :params, produces: EasyParams do |d|
          create(d)
        end

        factory :nulls

        params_factory.subclass.init do |d, r|
          create(d, r)
        end

        params_factory.subclass do
          def initialize(data, extra)
            super(data)
            @extra = extra
          end

          def get(diff)
            super() + @extra - diff
          end
        end

        nulls_factory.subclass do
          def initialize(data:, &block)
            block.call(data)
          end

          def null?
            true
          end
        end
      end
    end
  end

  describe 'concrete factory' do
    it 'handles classes' do
      expect(abstract_factory).to respond_to :params_factory
      factory = abstract_factory.params_factory
      expect(factory).to be_a Toritori::Factory
      expect(factory.base_class <= EasyParams).to be_truthy
    end

    it 'allows overriding of initialize proc' do
      factory = abstract_factory.params_factory
      expect { factory.create }.to raise_error ArgumentError
      instance = factory.create(2, 3)
      expect(instance).to be_a EasyParams
      expect(instance.get(4)).to eq 6 # 2 + 5 + 3 - 4
    end

    it 'supports anonimous classes' do
      expected = nil
      factory = abstract_factory.nulls_factory
      instance = factory.create(data: 2) do |data|
        expected = data
      end
      expect(instance).to be_null
      expect(expected).to eq 2
    end
  end
end
