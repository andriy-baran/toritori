# frozen_string_literal: true

class SubclassParams
  def self.create(data:)
    new(data)
  end

  def initialize(data)
    @data = data
  end

  def get
    @data + 5
  end
end

class ChildSubclassParams < SubclassParams
  def initialize(data, var)
    super(data)
    @var = var
  end

  def get
    super + @var
  end
end

SubclassQuery = Struct.new(:params)

RSpec.describe Toritori do
  vars do
    abstract_factory do
      Class.new do
        include Toritori

        factory :params, produces: SubclassParams, creation_method: :create
        factory :query, produces: SubclassQuery
      end
    end
    child_factory do
      Class.new(abstract_factory) do
        params_factory.subclass(produces: ChildSubclassParams, creation_method: :new)
      end
    end
  end

  describe 'concrete factory' do
    it 'handles classes' do
      expect(child_factory).to respond_to :params_factory
      factory = child_factory.params_factory
      expect(factory).to be_a Toritori::Factory
    end

    it 'simply creates instances' do
      factory = child_factory.params_factory
      expect { factory.create }.to raise_error ArgumentError
      instance = factory.create(2, 9)
      expect(instance.class <= SubclassParams).to be_truthy
      expect(instance.class).to eq ChildSubclassParams
      factory.create(3, 9)
      factory.create(4, 9)
      expect(instance.class.superclass).to eq SubclassParams
      expect(instance.get).to eq 16
    end

    it 'accepts only subclasses' do
      factory = child_factory.query_factory
      expect { factory.subclass(produces: ChildSubclassParams) }
        .to raise_error Toritori::SubclassError
      expect { factory.subclass(produces: '') }
        .to raise_error Toritori::NotAClassError
    end
  end
end
