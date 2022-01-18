# frozen_string_literal: true

require 'spec_helper'

describe Porridge::WhitelistFieldPolicy do
  describe '#allowed?' do
    def execute(whitelist, name, hierarchy)
      described_class.new(whitelist).allowed?(name, Object.new, field_hierarchy: hierarchy)
    end

    context 'with true field' do
      let(:result) do
        execute({ user: { organization: { id: true } } }, :id, %i[user organization])
      end

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'with non-true truthy field' do
      let(:result) do
        execute({ user: { organization: { id: 3.14 } } }, :id, %i[user organization])
      end

      it 'returns true' do
        expect(result).to eq true
      end
    end

    context 'with false field' do
      let(:result) do
        execute({ user: { organization: { id: false } } }, :id, %i[user organization])
      end

      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'with nil field' do
      let(:result) do
        execute({ user: { organization: { id: nil } } }, :id, %i[user organization])
      end

      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'with absent field' do
      let(:result) do
        execute({ user: { organization: { id: nil } } }, :name, %i[user organization])
      end

      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'with deeply absent field' do
      let(:result) do
        execute({ user: { organization: { id: nil } } }, :name, %i[user church])
      end

      it 'returns false' do
        expect(result).to eq false
      end
    end

    context 'with too-deep hierarchy' do
      let(:result) do
        execute({ user: { organization: true } }, :id, %i[user organization])
      end

      it 'returns false' do
        expect(result).to eq false
      end
    end
  end
end
