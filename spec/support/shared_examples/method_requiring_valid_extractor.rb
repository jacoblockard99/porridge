# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'a method requiring a valid extractor' do
  context 'with a valid extractor' do
    def _execute
      execute(extractor: Porridge::Extractor.new)
    end

    it 'raises no error' do
      expect { _execute }.not_to raise_error
    end
  end

  context 'with an invalid extractor' do
    def _execute
      execute(extractor: Object.new)
    end

    it 'raises an appropriate error' do
      expect { _execute }.to raise_error Porridge::InvalidExtractorError
    end
  end

  context 'with a nil serializer' do
    def _execute
      execute(extractor: nil)
    end

    it 'raises an appropriate error' do
      expect { _execute }.to raise_error Porridge::InvalidExtractorError
    end
  end
end
