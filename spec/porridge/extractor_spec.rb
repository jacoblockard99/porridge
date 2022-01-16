require 'spec_helper'

describe Porridge::Extractor do
  describe '.valid?' do
    context 'when given an object not implementing #call' do
      let(:result) { described_class.valid?(Object.new) }

      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'when given a proc' do
      let(:result) { described_class.valid?(proc {}) }

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'when given an Extractor' do
      let(:result) { described_class.valid?(described_class.new) }

      it 'returns true' do
        expect(result).to eq true
      end
    end
  end
end
