# frozen_string_literal: true

require 'spec_helper'

class EmptyDerivedDefinition < Porridge::SerializerDefinition; end

class DerivedDefinition < Porridge::SerializerDefinition
  attribute :id
  attribute :name
end

class DeeplyDerivedDefinition < DerivedDefinition
  attribute :email
end

describe Porridge::SerializerDefinition do
  let(:instance) { described_class }

  before { described_class.reset! }

  it_behaves_like 'SerializerDefiner'

  context 'when derived' do
    let(:instance) { EmptyDerivedDefinition }

    before { EmptyDerivedDefinition.reset! }

    it_behaves_like 'SerializerDefiner'
  end

  context 'when derived and modified' do
    let(:instance) { DerivedDefinition }

    it 'does not change the superclass' do
      expect(described_class.definer.added_serializers).to be_empty
    end
  end

  context 'when derived from with serializers and modified' do
    let(:instance) { DeeplyDerivedDefinition }

    it 'inherits the serializers' do
      expect(instance.definer.added_serializers.count).to eq 3
    end

    it 'does not change the superclasses', :aggregate_failures do
      expect(described_class.definer.added_serializers).to be_empty
      expect(DerivedDefinition.definer.added_serializers.count).to eq 2
    end
  end
end
