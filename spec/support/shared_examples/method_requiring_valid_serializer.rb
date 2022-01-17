# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'a method requiring a valid serializer' do
  context 'with a valid serializer' do
    def _execute
      execute(Porridge::Serializer.new)
    end

    it 'raises no error' do
      expect { _execute }.not_to raise_error
    end
  end

  context 'with an invalid serializer' do
    def _execute
      execute(Object.new)
    end

    it 'raises an appropriate error' do
      expect { _execute }.to raise_error Porridge::InvalidSerializerError
    end
  end

  context 'with a nil serializer' do
    def _execute
      execute(nil)
    end

    it 'raises an appropriate error' do
      expect { _execute }.to raise_error Porridge::InvalidSerializerError
    end
  end
end
