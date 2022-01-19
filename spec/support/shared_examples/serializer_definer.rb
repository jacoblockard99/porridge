# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'SerializerDefiner' do
  context 'when a nonexistent method is called' do
    it 'raises an appropriate error' do
      expect { instance.nonexistent }.to raise_error NoMethodError
    end
  end

  describe 'create_* methods' do
    it 'responds to the same ones as Factory', :aggregate_failures do
      expect(instance).to respond_to(:create_from_name_extractor)
      expect(instance).to respond_to(:create_custom_extractor)
      expect(instance).to respond_to(:create_association_extractor)
      expect(instance).to respond_to(:create_belongs_to_extractor)
      expect(instance).to respond_to(:create_has_many_extractor)
      expect(instance).to respond_to(:create_serializer)
      expect(instance).to respond_to(:create_chain_serializer)
      expect(instance).to respond_to(:create_serializers)
      expect(instance).to respond_to(:create_for_extracted_serializer)
      expect(instance).to respond_to(:create_serializer_for_extracted)
      expect(instance).to respond_to(:create_field_serializer)
      expect(instance).to respond_to(:create_attribute_field_serializer)
      expect(instance).to respond_to(:create_association_field_serializer)
      expect(instance).to respond_to(:create_belongs_to_field_serializer)
      expect(instance).to respond_to(:create_has_many_field_serializer)
    end

    it 'does not respond to invalid create_* methods' do
      expect(instance).not_to respond_to(:create_nonexistent)
    end

    it 'delegates correctly' do
      expect(instance.create_attribute_field_serializer(:name)).to be_a Porridge::FieldSerializer
    end
  end

  describe 'serializer methods' do
    it 'responds to serializer' do
      expect(instance).to respond_to(:serializer)
    end

    it 'responds to all *_serializer methods defined in Factory', :aggregate_failures do
      expect(instance).to respond_to(:chain)
      expect(instance).to respond_to(:for_extracted)
      expect(instance).to respond_to(:field)
      expect(instance).to respond_to(:attribute_field)
      expect(instance).to respond_to(:association_field)
      expect(instance).to respond_to(:belongs_to_field)
      expect(instance).to respond_to(:has_many_field)
    end

    it 'does not respond to non-serializer methods defined in Factory', :aggregate_failures do
      expect(instance).not_to respond_to(:from_name_extractor)
      expect(instance).not_to respond_to(:custom_extractor)
      expect(instance).not_to respond_to(:association_extractor)
      expect(instance).not_to respond_to(:belongs_to_extractor)
      expect(instance).not_to respond_to(:has_many_extractor)
    end

    it 'does not respond to nonexistent methods' do
      expect(instance).not_to respond_to(:nonexistent_serializer)
    end

    context 'when called' do
      before { instance.attribute_field(:name) }

      it 'delegates correctly', :aggregate_failures do
        expect(instance.added_serializers.count).to eq 1
        expect(instance.added_serializers.first).to be_a Porridge::FieldSerializer
      end
    end
  end

  describe 'field methods' do
    it 'responds to all *_field methods defined in Factory', :aggregate_failures do
      expect(instance).to respond_to(:attribute)
      expect(instance).to respond_to(:association)
      expect(instance).to respond_to(:belongs_to)
      expect(instance).to respond_to(:has_many)
    end

    it 'does not respond to nonexistent methods', :aggregate_failures do
      expect(instance).not_to respond_to(:nonexistent_field)
      expect(instance).not_to respond_to(:nonexistent_field_serializer)
    end

    context 'when called' do
      before { instance.attribute(:name) }

      it 'delegates correctly', :aggregate_failures do
        expect(instance.added_serializers.count).to eq 1
        expect(instance.added_serializers.first).to be_a Porridge::FieldSerializer
      end
    end
  end

  describe '#defined_serializer' do
    before do
      instance.attribute(:name)
      instance.attribute(:email)
    end

    let(:object) { Struct.new(:name, :email).new('Jacob', 'example@example.com') }
    let(:result) { instance.defined_serializer }

    it 'returns a serializer that chains all the defined ones' do
      expect(result.call(object, {},
                         field_policy: Porridge::FieldPolicy.new)).to eq({ name: 'Jacob',
                                                                           email: 'example@example.com' })
    end
  end

  describe '#call' do
    before do
      instance.attribute(:name)
      instance.attribute(:email)
    end

    let(:object) { Struct.new(:name, :email).new('Jacob', 'example@example.com') }

    it 'returns delegates to the defined serializer' do
      expect(instance.call(object, {},
                           field_policy: Porridge::FieldPolicy.new)).to eq({ name: 'Jacob',
                                                                             email: 'example@example.com' })
    end
  end
end
