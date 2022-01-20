# frozen_string_literal: true

require 'spec_helper'

describe Porridge::ChainSerializer do
  describe '.new?' do
    context 'when given a single, invalid serializer' do
      def execute
        described_class.new(Object.new)
      end

      it 'raises an appropriate error' do
        expect { execute }.to raise_error Porridge::InvalidSerializerError
      end
    end

    context 'when given multiple serializers, some valid, some invalid' do
      def execute
        described_class.new(Porridge::Serializer.new, Object.new, Porridge::Serializer.new)
      end

      it 'raises an appropriate error' do
        expect { execute }.to raise_error Porridge::InvalidSerializerError
      end
    end

    context 'when given no serializers' do
      def execute
        described_class.new
      end

      it 'does not raise an error' do
        expect { execute }.not_to raise_error
      end
    end
  end

  describe '#call' do
    let(:instance) do
      described_class.new(
        proc do |_obj, input, _opts|
          input[:one] = 1
          input
        end,
        proc do |obj, input, _opts|
          input[:dynamic] = obj[:field]
          input
        end,
        proc do |_obj, input, opts|
          input[:opt] = opts[:opt]
          input
        end
      )
    end

    context 'with valid arguments' do
      let(:result) { instance.call({ field: 'love' }, { initial: 'the' }, { opt: 'Lord' }) }

      it 'returns the correct result' do
        expect(result).to eq({
          initial: 'the',
          one: 1,
          dynamic: 'love',
          opt: 'Lord'
        })
      end
    end

    context 'with a chain serializer with no serializers' do
      let(:instance) { described_class.new }
      let(:result) { instance.call(Object.new, 'input', {}) }

      it 'returns the unchanged input' do
        expect(result).to eq 'input'
      end
    end
  end
end
