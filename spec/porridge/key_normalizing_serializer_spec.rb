# frozen_string_literal: true

require 'spec_helper'

describe Porridge::KeyNormalizingSerializer do
  describe '.new' do
    def execute(...)
      described_class.new(...)
    end

    it_behaves_like 'a method requiring a valid serializer'
  end

  describe '#call' do
    context 'with valid serializer and arguments' do
      def create_instance(type)
        described_class.new(proc { { trust: 'in', the: 'Lord', 'your' => 'God' } }, key_type: type)
      end

      context 'with string key type' do
        let(:instance) do
          described_class.new(
            proc {
              {
                trust: 'in',
                the: 'Lord',
                'your' => 'God'
              }
            },
            key_type: :string
          )
          create_instance(:string)
        end
        let(:result) { instance.call(Object.new, Object.new, {}) }

        it 'stringifies the keys' do
          expect(result).to eq({
            'trust' => 'in',
            'the' => 'Lord',
            'your' => 'God'
          })
        end
      end

      context 'with symbol key type' do
        let(:instance) { create_instance(:symbol) }
        let(:result) { instance.call(Object.new, Object.new, {}) }

        it 'symbolizes the keys' do
          expect(result).to eq({
            trust: 'in',
            the: 'Lord',
            your: 'God'
          })
        end
      end
    end
  end
end
