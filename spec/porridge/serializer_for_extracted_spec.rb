# frozen_string_literal: true

require 'spec_helper'

describe Porridge::SerializerForExtracted do
  describe '.new' do
    def execute(serializer: Porridge::Serializer.new, extractor: Porridge::Extractor.new)
      described_class.new(serializer, extractor: extractor)
    end

    it_behaves_like 'a method requiring a valid serializer'

    it_behaves_like 'a method requiring a valid extractor'
  end

  describe '#call' do
    let(:extractor) { proc { |obj| obj[:value] } }
    let(:serializer) { proc { |obj| obj } }
    let(:instance) { described_class.new(serializer, extractor: extractor) }
    let(:result) { instance.call({value: 'a random value'}, Object.new, {}) }

    it "extracts the value and passes that as the serializer's object" do
      expect(result).to eq 'a random value'
    end
  end
end
