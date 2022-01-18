# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'a method requiring a valid field policy' do
  context 'with a valid field policy' do
    def _execute
      execute(field_policy: Porridge::FieldPolicy.new)
    end

    it 'raises no error' do
      expect { _execute }.not_to raise_error
    end
  end

  context 'with an invalid field policy' do
    def _execute
      execute(field_policy: Object.new)
    end

    it 'raises an appropriate error' do
      expect { _execute }.to raise_error Porridge::InvalidFieldPolicyError
    end
  end

  context 'with a nil field policy' do
    def _execute
      execute(field_policy: nil)
    end

    it 'raises an appropriate error' do
      expect { _execute }.to raise_error Porridge::InvalidFieldPolicyError
    end
  end
end
