# frozen_string_literal: true

require 'spec_helper'

describe Porridge::Serializer do
  describe '.valid?' do
    context 'when given an object not implementing #call' do
      let(:result) { described_class.valid?(Object.new) }

      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'when given a proc' do
      let(:result) { described_class.valid?(proc {} ) }

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'when given a Serializer' do
      let(:result) { described_class.valid?(described_class.new) }

      it 'returns true' do
        expect(result).to eq true
      end
    end
  end

  describe '.ensure_valid!' do
    context 'when given all valid serializers' do
      let(:result) { described_class.ensure_valid!(Porridge::Serializer.new, proc {}, Porridge::Serializer.new) }

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'when given no serializers' do
      let(:result) { described_class.ensure_valid! }

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'when given a single, invalid serializer' do
      def execute
        described_class.ensure_valid!(Object.new)
      end

      it 'raises an appropriate error' do
        expect { execute }.to raise_error Porridge::InvalidSerializerError
      end
    end

    context 'when given multiple serializers, some valid, some invalid' do
      def execute
        described_class.ensure_valid!(proc {}, Porridge::Serializer.new, Object.new)
      end

      it 'raises an appropriate error' do
        expect { execute }.to raise_error Porridge::InvalidSerializerError
      end
    end
  end

  describe '#call' do
    it 'returns the input' do
      expect(described_class.new.call(Object.new, 'input', {})).to eq 'input'
    end
  end
end
