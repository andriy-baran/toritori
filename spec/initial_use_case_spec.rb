# frozen_string_literal: true

class EasyParams
  def initialize(data)
    @data = data
  end
end

RSpec.describe Toritori do
  vars do
    abstract_factory do
      Class.new do
        include Toritori

        factory :params, produces: EasyParams

        params_factory.subclass do
          def get
            @data + 5
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
    end

    it 'simply creates instances' do
      factory = abstract_factory.params_factory
      expect { factory.create }.to raise_error ArgumentError
      instance = factory.create(2)
      expect(instance.class <= EasyParams).to be_truthy
      expect(instance).to be_a EasyParams
      expect(instance.get).to eq 7
    end
  end

  describe '#create' do
    it 'accepts factory name as first argument' do
      instance = abstract_factory.create(:params, 2)
      expect(instance).to be_a EasyParams
      expect(instance.get).to eq 7
    end
  end
end
