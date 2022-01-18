# frozen_string_literal: true

require 'spec_helper'

describe Porridge::SerializingExtractor do
  describe '.new' do
    def execute(extractor: Porridge::Extractor.new, serializer: Porridge::Serializer.new)
      described_class.new(extractor, serializer)
    end

    it_behaves_like 'a method requiring a valid extractor'

    it_behaves_like 'a method requiring a valid serializer'
  end

  describe '#call' do
    # Disabling since this doesn't really matter in specs.
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def execute(object: 'initial object', options: { initial: 'options' })
      results = { extractor: {}, serializer: {} }
      extractor = proc do |obj, opts|
        results[:extractor][:object] = obj
        results[:extractor][:options] = opts
        'initial extracted value'
      end
      serializer = proc do |obj, input, opts|
        results[:serializer][:object] = obj
        results[:serializer][:input] = input
        results[:serializer][:options] = opts
        'final serialized value'
      end
      instance = described_class.new(extractor, serializer)
      results[:output] = instance.call(object, options)
      results
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    let(:results) { execute }

    it 'returns the properly serialized value' do
      expect(results[:output]).to eq 'final serialized value'
    end

    it 'gives the extractor the proper arguments', :aggregate_failures do
      expect(results[:extractor][:object]).to eq 'initial object'
      expect(results[:extractor][:options]).to eq({ initial: 'options' })
    end

    it 'gives the serializer the proper arguments', :aggregate_failures do
      expect(results[:serializer][:object]).to eq 'initial extracted value'
      expect(results[:serializer][:input]).to eq({})
      expect(results[:serializer][:options]).to eq({ initial: 'options' })
    end
  end
end
