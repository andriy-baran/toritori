# frozen_string_literal: true

class EasyParams
  def initialize(data)
    @data = data
  end
end

RSpec.describe Toritori do
  vars do
    factory do
      Class.new do
        include Toritori

        produces :params, EasyParams, ->(k, d) { k.new(d) }

        params_factory.patch_class do
          def get
            @data + 5
          end
        end
      end
    end
  end

  it "simply creates instances" do
    expect(factory).to respond_to(:params)
    expect(factory).to respond_to(:params_factory)
    expect(factory.params_factory).to be_a(Toritori::Factory)
    instance = factory.params_factory.create(2)
    expect(instance).to be_a(EasyParams)
    expect(instance.get).to eq(7)
  end
end
