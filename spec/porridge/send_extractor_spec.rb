# frozen_string_literal: true

require 'spec_helper'

class DummyObject
  def name
    'result'
  end
end

describe Porridge::SendExtractor do
  describe '#call' do
    context 'when given a symbol method name' do
      let(:instance) { described_class.new(:name) }
      let(:result) { instance.call(DummyObject.new, {}) }

      it 'returns the result of calling the method' do
        expect(result).to eq 'result'
      end
    end

    context 'when given a string method name' do
      let(:instance) { described_class.new('name') }
      let(:result) { instance.call(DummyObject.new, {}) }

      it 'returns the result of calling the method' do
        expect(result).to eq 'result'
      end
    end

    context 'when given an object that does not respond to the method' do
      let(:instance) { described_class.new(:name) }
      let(:result) { instance.call(Object.new, {}) }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
