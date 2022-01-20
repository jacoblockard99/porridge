# frozen_string_literal: true

require 'spec_helper'

class FactoryOverridingAliasSource < Porridge::Factory
  def association_extractor(...)
    'expected'
  end

  def association_field_serializer(...)
    'expected'
  end

  def chain_serializer(...)
    'expected'
  end

  def for_extracted_serializer(...)
    'expected'
  end
end

describe Porridge::Factory do
  let(:instance) { described_class.new }

  describe '#extractor' do
    context 'when given a valid extractor' do
      let(:extractor) { Porridge::Extractor.new }
      let(:result) { instance.extractor(extractor) }

      it 'returns the extractor' do
        expect(result).to eq extractor
      end
    end

    context 'when given an invalid extractor' do
      let(:extractor) { Object.new }
      let(:result) { instance.extractor(extractor) }

      it 'raises an appropriate error' do
        expect { result }.to raise_error Porridge::InvalidExtractorError
      end
    end

    context 'when given a nil extractor' do
      let(:extractor) { nil }
      let(:result) { instance.extractor(extractor) }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '#from_name_extractor' do
    let(:result) { instance.from_name_extractor(:length) }

    it 'returns an extractor that sends a method to the object' do
      expect(result.call('aaaa', {})).to eq 4
    end
  end

  describe '#custom_extractor' do
    let(:result) { instance.custom_extractor(proc { |obj| obj.reverse }) }

    it 'returns an extractor that calls the callback' do
      expect(result.call('abc', {})).to eq 'cba'
    end
  end

  describe '#attribute_extractor' do
    context 'when given only name' do
      let(:result) { instance.attribute_extractor(name: :length) }

      it 'returns an extractor that sends a method to the object' do
        expect(result.call('abcde', {})).to eq 5
      end
    end

    context 'when given a callback' do
      let(:result) { instance.attribute_extractor(callback: proc { |obj| obj.reverse }) }

      it 'returns a serializer that adds a field via calling the callback' do
        expect(result.call('abc', {})).to eq 'cba'
      end
    end

    context 'when given a block' do
      let(:result) { instance.attribute_extractor { |obj, _opts| obj.reverse } }

      it 'returns a serializer that adds a field via calling the block' do
        expect(result.call('abc', {})).to eq 'cba'
      end
    end
  end

  shared_examples_for '#association_extractor' do
    let(:serializer) { proc { |obj| obj } }

    context 'with explicit extractor' do
      let(:extractor) { proc { |obj| obj[:association] } }
      let(:result) { execute(serializer: serializer, extractor: extractor) }

      it 'returns an extractor that uses the explicit extractor' do
        expect(result.call({ association: 'value' }, {})).to eq 'value'
      end
    end

    context 'with extraction name' do
      let(:result) { execute(serializer: serializer, extraction_name: :reverse) }

      it 'returns an extractor that sends a method to the object' do
        expect(result.call('abc', {})).to eq 'cba'
      end
    end

    context 'with callback' do
      let(:callback) { proc { |obj| obj * 10 } }
      let(:result) { execute(serializer: serializer, callback: callback) }

      it 'returns an extractor that calls the callback' do
        expect(result.call(50, {})).to eq 500
      end
    end

    context 'with block' do
      let(:result) { execute(serializer: serializer) { |obj| obj * 5 } }

      it 'returns an extractor that calls the callback' do
        expect(result.call('a', {})).to eq 'aaaaa'
      end
    end
  end

  describe '#association_extractor' do
    def execute(...)
      instance.association_extractor(...)
    end

    it_behaves_like '#association_extractor'
  end

  describe '#belongs_to_extractor' do
    def execute(...)
      instance.belongs_to_extractor(...)
    end

    it_behaves_like '#association_extractor'

    context 'when #association_extraction is overriden' do
      let(:instance) { FactoryOverridingAliasSource.new }

      it 'uses the override' do
        expect(instance.belongs_to_extractor).to eq 'expected'
      end
    end
  end

  describe '#has_many_extractor' do
    def execute(...)
      instance.has_many_extractor(...)
    end

    it_behaves_like '#association_extractor'

    context 'when #association_extraction is overriden' do
      let(:instance) { FactoryOverridingAliasSource.new }

      it 'uses the override' do
        expect(instance.has_many_extractor).to eq 'expected'
      end
    end
  end

  describe '#serializer' do
    context 'when given a valid serializer' do
      let(:serializer) { Porridge::Serializer.new }
      let(:result) { instance.serializer(serializer) }

      it 'returns the serializer' do
        expect(result).to eq serializer
      end
    end

    context 'when given an invalid serializer' do
      let(:serializer) { Object.new }
      let(:result) { instance.serializer(serializer) }

      it 'raises an appropriate error' do
        expect { result }.to raise_error Porridge::InvalidSerializerError
      end
    end

    context 'when given a nil serializer' do
      let(:serializer) { nil }
      let(:result) { instance.serializer(serializer) }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    shared_examples_for '#chain_serializer' do
      let(:serializers) do
        [
          proc { |_obj, hash|
            hash[:one] = 1
            hash
          },
          proc { |_obj, hash|
            hash[:two] = 2
            hash
          },
          proc { |_obj, hash|
            hash[:three] = 3
            hash
          }
        ]
      end
      let(:result) { execute(serializers) }

      it 'returns a serializer that chains the given ones' do
        expect(result.call(Object.new, { zero: 0 }, {})).to eq({
          zero: 0,
          one: 1,
          two: 2,
          three: 3
        })
      end
    end

    describe '#chain_serializer' do
      def execute(serializers)
        instance.chain_serializer(*serializers)
      end

      it_behaves_like '#chain_serializer'
    end

    describe '#serializers' do
      def execute(serializers)
        instance.serializers(*serializers)
      end

      it_behaves_like '#chain_serializer'

      context 'when #chain_serializer is overriden' do
        let(:instance) { FactoryOverridingAliasSource.new }

        it 'uses the override' do
          expect(instance.serializers).to eq 'expected'
        end
      end
    end

    shared_examples_for '#for_extracted_serializer' do
      let(:serializer) { proc { |obj| "#{obj}_serialized" } }
      let(:extractor) { proc { |obj| "#{obj}_extracted" } }
      let(:result) { execute(serializer, extractor) }

      it 'returns a serializer that serializes the extracted value' do
        expect(result.call('input', {}, {})).to eq 'input_extracted_serialized'
      end
    end

    describe '#for_extracted_serializer' do
      def execute(serializer, extractor)
        instance.for_extracted_serializer(serializer, extractor)
      end

      it_behaves_like '#for_extracted_serializer'
    end

    describe '#serializer_for_extracted' do
      def execute(serializer, extractor)
        instance.serializer_for_extracted(serializer, extractor)
      end

      it_behaves_like '#for_extracted_serializer'

      context 'when #for_extracted_serializer is overriden' do
        let(:instance) { FactoryOverridingAliasSource.new }

        it 'uses the override' do
          expect(instance.serializer_for_extracted).to eq 'expected'
        end
      end
    end

    describe '#field_serializer' do
      let(:extractor) { proc { |obj| "#{obj}_extracted" } }
      let(:result) { instance.field_serializer(:key, extractor) }

      it 'returns a serializer that adds a field' do
        expect(result.call('input', {}, field_policy: Porridge::FieldPolicy.new)).to eq({ key: 'input_extracted' })
      end
    end

    describe '#attribute_field_serializer' do
      context 'when given only name' do
        let(:result) { instance.attribute_field_serializer(:length) }

        it 'returns a serializer that adds a field via sending a method to the object' do
          expect(result.call('abcde', {}, field_policy: Porridge::FieldPolicy.new)).to eq({ length: 5 })
        end
      end

      context 'when given a name and an extraction name' do
        let(:result) { instance.attribute_field_serializer(:bigness, extraction_name: :length) }

        it 'returns a serializer that adds a field via sending the extraction name to the object' do
          expect(result.call('abcd', {}, field_policy: Porridge::FieldPolicy.new)).to eq({ bigness: 4 })
        end
      end

      context 'when given a name and a callback' do
        let(:result) { instance.attribute_field_serializer(:reversed, proc { |obj| obj.reverse }) }

        it 'returns a serializer that adds a field via calling the callback' do
          expect(result.call('abc', {}, field_policy: Porridge::FieldPolicy.new)).to eq({ reversed: 'cba' })
        end
      end

      context 'when given a name and a block' do
        let(:result) { instance.attribute_field_serializer(:reversed) { |obj, _opts| obj.reverse } }

        it 'returns a serializer that adds a field via calling the block' do
          expect(result.call('abc', {}, field_policy: Porridge::FieldPolicy.new)).to eq({ reversed: 'cba' })
        end
      end
    end

    describe '#attributes_field_serializer' do
      context 'when given no names' do
        let(:result) { instance.attributes_field_serializer }

        it 'returns a serializer that does nothing' do
          expect(result.call(Object.new, 'input', {})).to eq 'input'
        end
      end

      context 'when given names' do
        let(:result) { instance.attributes_field_serializer(:name, :email, :id) }
        let(:object) { Struct.new(:name, :email, :id).new('Jacob', 'example@example.com', 123) }

        it 'returns a serializer that adds all the provided fields' do
          expect(result.call(object, {}, field_policy: Porridge::FieldPolicy.new)).to eq({
            name: 'Jacob',
            email: 'example@example.com',
            id: 123
          })
        end
      end
    end

    shared_examples_for '#association_field_serializer' do
      context 'when given only a name and a serializer' do
        let(:serializer) { proc { |obj| obj } }
        let(:result) { execute(:associated, serializer: serializer) }
        let(:object) { Struct.new(:associated).new('input object') }

        it 'returns a serializer that adds a field via serializing the result of calling the method' do
          expect(result.call(object, {}, field_policy: Porridge::FieldPolicy.new)).to eq(associated: 'input object')
        end
      end

      context 'when a name, an extraction name, and a serializer' do
        let(:serializer) { proc { |obj| obj } }
        let(:result) { execute(:association, extraction_name: :associated, serializer: serializer) }
        let(:object) { Struct.new(:associated).new('input object') }

        it 'returns a serializer that adds a field via serializing the result of calling the method' do
          expect(result.call(object, {}, field_policy: Porridge::FieldPolicy.new)).to eq(association: 'input object')
        end
      end
    end

    describe '#association_field_serializer' do
      def execute(...)
        instance.association_field_serializer(...)
      end

      it_behaves_like '#association_field_serializer'
    end

    describe '#belongs_to_field_serializer' do
      def execute(...)
        instance.belongs_to_field_serializer(...)
      end

      it_behaves_like '#association_field_serializer'

      context 'when #association_field_serializer is overriden' do
        let(:instance) { FactoryOverridingAliasSource.new }

        it 'uses the override' do
          expect(instance.belongs_to_field_serializer).to eq 'expected'
        end
      end
    end

    describe '#has_many_field_serializer' do
      def execute(...)
        instance.has_many_field_serializer(...)
      end

      it_behaves_like '#association_field_serializer'

      context 'when #association_field_serializer is overriden' do
        let(:instance) { FactoryOverridingAliasSource.new }

        it 'uses the override' do
          expect(instance.has_many_field_serializer).to eq 'expected'
        end
      end
    end
  end
end
