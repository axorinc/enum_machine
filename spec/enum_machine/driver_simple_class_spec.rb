# frozen_string_literal: true

class TestClass

  attr_accessor :state

  def initialize(state)
    @state = state
  end

  include EnumMachine[state: { enum: %w[choice in_delivery] }]

end

RSpec.describe 'DriverSimpleClass' do
  subject(:item) { TestClass.new('choice') }

  it { expect(item.state).to be_choice }
  it { expect(item.state).not_to be_in_delivery }
  it { expect(item.state).to eq 'choice' }
  it { expect(item.state.frozen?).to eq true }

  describe 'module' do
    it 'returns state string' do
      expect(TestClass::STATE::IN_DELIVERY).to eq 'in_delivery'
      expect(TestClass::STATE::IN_DELIVERY).to be_frozen
    end

    it 'returns state array' do
      expect(TestClass::STATE::CHOICE__IN_DELIVERY).to eq %w[choice in_delivery]
      expect(TestClass::STATE::CHOICE__IN_DELIVERY).to be_frozen
    end

    it 'raise exceptions unexists state' do
      expect { TestClass::STATE::CHOICE__CANCELLED }.to raise_error(NameError, 'uninitialized constant TestClass::STATE::CANCELLED')
    end

    it 'pretty print errors' do
      expect { item.state.human_name }.to raise_error(NoMethodError, /undefined method.+EnumMachine:BuildAttribute.+value=choice/)
    end

    context 'when state is changed' do
      it 'returns changed state string' do
        item.state = 'choice'
        state_was = item.state

        item.state = 'in_delivery'

        expect(item.state).to eq 'in_delivery'
        expect(state_was).to eq 'choice'
      end
    end
  end

  context 'when definition order is changed' do
    let(:invert_definition_class) do
      Class.new do
        include EnumMachine[state: { enum: %w[choice in_delivery] }]
        attr_accessor :state
      end
    end

    it 'nothing raised' do
      expect { invert_definition_class }.not_to raise_error

      item = invert_definition_class.new
      item.state = 'choice'

      expect(item.state).to be_choice
    end
  end
end
