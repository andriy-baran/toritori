# frozen_string_literal: true

class EasyParams
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

        produces :params, EasyParams, ->(k, d) { k.new(d) }

        params_factory.init = ->(k, d, r) { k.new(d, r) }
        params_factory.patch_class do
          def initialize(data, extra)
            super(data)
            @extra = extra
          end

          def get(diff)
            super() + @extra - diff
          end
        end
      end
    end
  end

  describe "concrete factory" do
    it "handles classes" do
      expect(abstract_factory).to respond_to :params_factory
      factory = abstract_factory.params_factory
      expect(factory).to be_a Toritori::Factory
      expect(factory.base_class).to eq EasyParams
      expect(factory.subclass <= EasyParams).to be_truthy
    end

    it "allows overriding of initialize proc" do
      factory = abstract_factory.params_factory
      expect { factory.create }.to raise_error ArgumentError
      instance = factory.create(2, 3)
      expect(instance).to be_a EasyParams
      expect(instance.get(4)).to eq 6 # 2 + 5 + 3 - 4
    end

    it 'raises error if init is not lambda' do
      expect {
        abstract_factory.params_factory.init = nil
      }.to raise_error(ArgumentError, /init must be a lambda/)

      expect {
        abstract_factory.params_factory.init = Proc.new {}
      }.to raise_error(ArgumentError, /init must be a lambda/)
    end

    it 'raises error if init lambda has wrong arity' do
      expect {
        abstract_factory.params_factory.init = -> { nil }
      }.to raise_error(ArgumentError, /init lambda must have at least one required argument/)

      expect {
        abstract_factory.params_factory.init = ->(*a) { a.size }
      }.to raise_error(ArgumentError, /init lambda must have at least one required argument/)
    end
  end
end
