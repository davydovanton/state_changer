RSpec.describe StateChanger::Container do
  let(:container) { described_class.new }

  describe '#register' do
    it 'registers new objects' do
      container.register(:key1, Object.new)
      container.register(:key2, Object.new)
      container.register(:key3) { |data| puts data }

      expect(container.keys).to eq(['key1', 'key2', 'key3'])
    end
  end

  describe '#[]' do
    subject { container[key] }

    context 'when value is block' do
      let(:key) { :state }

      it 'returns block as a value' do
        container.register(:state) { |data| [data] }

        expect(subject).to be_a(Proc)
        expect(subject.call(1)).to eq([1])
      end
    end

    context 'when key is symbol and registered key is symbol' do
      let(:key) { :state }

      it 'returns value for key' do
        container.register(:state, 'red')

        expect(subject).to eq('red')
      end
    end

    context 'when key is string and registered key is symbol' do
      let(:key) { 'state' }

      it 'returns value for key' do
        container.register(:state, 'red')

        expect(subject).to eq('red')
      end
    end

  end

  describe '#keys' do
    subject { container.keys }

    it 'returns all registered keys from container' do
      container.register(:key1, Object.new)
      container.register(:key2, Object.new)

      expect(subject).to eq(['key1', 'key2'])
    end
  end
end
