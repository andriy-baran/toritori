
RSpec.describe Toritori do
  vars do
    factory do
      Class.new do
        include Toritori

        class EasyParams; end

        factory :params, EasyParams, %i(find new)

        params do
          def get; end
        end
      end
    end
  end

  it 'is sipmle to create instances' do
    expect(factory).to respond_to(:params)
    expect(factory.factories).to be_a(Hash)
    expect(factory.params).to be_a(Toritori::Factory)
    expect(factory.new_params).to be_a(Hash)
    expect(factory.find_params).to be_a(Hash)
  end
end