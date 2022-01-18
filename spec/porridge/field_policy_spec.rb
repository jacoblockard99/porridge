# frozen_string_literal: true

require 'spec_helper'

describe Porridge::FieldPolicy do
  describe '.valid?' do
    context 'when given an object not implementing #allowed?' do
      let(:result) { described_class.valid?(Object.new) }

      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'when given a proc' do
      let(:result) { described_class.valid?(proc {}) }

      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'when given a FieldPolicy' do
      let(:result) { described_class.valid?(described_class.new) }

      it 'returns true' do
        expect(result).to eq true
      end
    end
  end

  describe '.ensure_valid!' do
    context 'when given all valid field policies' do
      let(:result) { described_class.ensure_valid!(described_class.new, described_class.new) }

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'when given no field policies' do
      let(:result) { described_class.ensure_valid! }

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'when given a single, invalid field policy' do
      def execute
        described_class.ensure_valid!(Object.new)
      end

      it 'raises an appropriate error' do
        expect { execute }.to raise_error Porridge::InvalidFieldPolicyError
      end
    end

    context 'when given multiple field policies, some valid, some invalid' do
      def execute
        described_class.ensure_valid!(described_class.new, described_class.new, Object.new)
      end

      it 'raises an appropriate error' do
        expect { execute }.to raise_error Porridge::InvalidFieldPolicyError
      end
    end
  end
end
