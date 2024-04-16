# frozen_string_literal: true

class MethodParams
  attr_reader :data

  def initialize(data)
    @data = data
  end
end

class ParamsFactory
  include Toritori
  factory :params, produces: MethodParams
end

RSpec.describe Toritori do
  vars do
    test_factory do
      Class.new do
        include Toritori
        factory :params,
                produces: MethodParams,
                creation_method: ->(*args, **kwargs, &block) { ParamsFactory.create(:params, *args, **kwargs, &block) }

        factory :params2, produces: MethodParams do |*args, **kwargs, &block|
          ParamsFactory.create(:params, *args, **kwargs, &block)
        end
      end
    end
  end

  describe 'concrete factory' do
    it 'handles classes' do
      expect(ParamsFactory).to receive(:create).with(:params, 1).and_call_original
      expect(ParamsFactory).to receive(:create).with(:params, 2).and_call_original
      expect(test_factory).to respond_to :params_factory
      instance = test_factory.create(:params, 1)
      instance2 = test_factory.create(:params2, 2)
      expect(instance.data).to eq 1
      expect(instance2.data).to eq 2
    end
  end
end
