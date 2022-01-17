# frozen_string_literal: true

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

  describe '.ensure_valid!' do
    context 'when given all valid extractors' do
      let(:result) { described_class.ensure_valid!(described_class.new, proc {}, described_class.new) }

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'when given no extractors' do
      let(:result) { described_class.ensure_valid! }

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'when given a single, invalid extractor' do
      def execute
        described_class.ensure_valid!(Object.new)
      end

      it 'raises an appropriate error' do
        expect { execute }.to raise_error Porridge::InvalidExtractorError
      end
    end

    context 'when given multiple extractors, some valid, some invalid' do
      def execute
        described_class.ensure_valid!(proc {}, described_class.new, Object.new)
      end

      it 'raises an appropriate error' do
        expect { execute }.to raise_error Porridge::InvalidExtractorError
      end
    end
  end
end
