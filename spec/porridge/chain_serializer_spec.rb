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
  end

  describe '#call' do
    let(:instance) do
      described_class.new(
        proc do |obj, input, opts|
          input[:one] = 1
          input
        end,
        proc do |obj, input, opts|
          input[:dynamic] = obj[:field]
          input
        end,
        proc do |obj, input, opts|
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
  end
end
