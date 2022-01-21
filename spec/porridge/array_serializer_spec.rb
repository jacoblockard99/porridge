# frozen_string_literal: true

require 'spec_helper'

class OverridenArraySerializer < Porridge::ArraySerializer
  protected

  def array?(_object)
    false
  end
end

describe Porridge::ArraySerializer do
  describe '.new' do
    def execute(serializer:)
      described_class.new(serializer)
    end

    it_behaves_like 'a method requiring a valid serializer'
  end

  describe '#call' do
    let(:instance) do
      described_class.new(proc { |_obj, input, _opts| input * 5 })
    end

    context 'when given a standard object' do
      let(:result) { instance.call(Object.new, 10, {}) }

      it 'delegates to the base serializer' do
        expect(result).to eq 50
      end
    end

    context 'when given a hash' do
      let(:instance) { described_class.new(proc { |obj| obj }) }
      let(:result) { instance.call({ initial: true }, {}, {}) }

      it 'does not treat it as an array' do
        expect(result).to eq({ initial: true })
      end
    end

    context 'when given an array' do
      let(:result) { instance.call([Object.new, Object.new, Object.new], 5, {}) }

      it 'returns an array of each output' do
        expect(result).to eq [25, 25, 25]
      end

      context 'when array? is overriden' do
        let(:instance) do
          OverridenArraySerializer.new(proc { |obj| obj })
        end
        let(:result) { instance.call([1, 2, 3], 'value', {}) }

        it 'does not treat it as an array' do
          expect(result).to eq [1, 2, 3]
        end
      end
    end
  end
end
