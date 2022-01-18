# frozen_string_literal: true

require 'spec_helper'

class ImpossibleFieldPolicy < Porridge::FieldPolicy
  def allowed?(_name, _object, _options)
    false
  end
end

describe Porridge::FieldSerializer do
  describe '#new' do
    def execute(extractor:)
      described_class.new(:name, extractor)
    end

    it_behaves_like 'a method requiring a valid extractor'
  end

  describe '#call' do
    describe 'its field policy option' do
      let(:instance) { described_class.new(:field_name, Porridge::Extractor.new) }

      def execute(field_policy:)
        instance.call(Object.new, {}, field_policy: field_policy)
      end

      it_behaves_like 'a method requiring a valid field policy'

      context 'without a field policy' do
        def execute
          instance.call(Object.new, {}, {})
        end

        it 'raises an appropriate error' do
          expect { execute }.to raise_error Porridge::InvalidFieldPolicyError
        end
      end
    end

    context 'with a disallowed field' do
      let(:object) { Object.new }
      let(:input_hash) { { initial: true } }
      let(:options) { { field_policy: ImpossibleFieldPolicy.new } }
      let(:instance) { described_class.new(:field_name, Porridge::Extractor.new) }
      let(:result) { instance.call(object, input_hash, options) }

      it 'returns the initial hash' do
        expect(result).to eq input_hash
      end

      it 'does not change the initial hash' do
        expect { result }.not_to(change { input_hash })
      end

      it 'does not change the object' do
        expect { result }.not_to(change { object })
      end

      it 'does not change the options' do
        expect { result }.not_to(change { options })
      end
    end

    context 'with valid setup' do
      def execute(object: 'object', input: {}, options: {}, name: :field_name, value: 'value')
        results = {}
        instance = described_class.new(name, proc do |obj, opts|
          results[:object] = obj
          results[:options] = opts
          value
        end)
        options[:field_policy] ||= Porridge::FieldPolicy.new
        results[:output] = instance.call(object, input, options)
        results
      end

      context 'with typical setup' do
        let(:result) { execute(input: { initial: 10 })[:output] }

        it 'adds the field to the input hash' do
          expect(result).to eq({
            initial: 10,
            field_name: 'value'
          })
        end
      end

      context 'with oddly-typed name' do
        let(:name) { Object.new }
        let(:result) { execute(name: name)[:output] }

        it 'does not touch it' do
          expect(result).to eq({ name => 'value' })
        end
      end

      context 'with no field hierarchy provided' do
        let(:options) { { field_policy: Porridge::FieldPolicy.new } }
        let(:results) { execute(options: options) }

        it 'creates the new array with the field name' do
          expect(results[:options][:field_hierarchy]).to eq [:field_name]
        end

        it 'does not change the original options hash' do
          expect { results }.not_to(change { options })
        end
      end

      context 'with an existing empty field hierarchy' do
        let(:field_hierarchy) { [] }
        let(:options) { { field_hierarchy: field_hierarchy, field_policy: Porridge::FieldPolicy.new } }
        let(:results) { execute(options: options) }

        it 'adds the field name' do
          expect(results[:options][:field_hierarchy]).to eq [:field_name]
        end

        it 'does not change the original options hash' do
          expect { results }.not_to(change { options })
        end
      end

      context 'with an existing field hierarchy' do
        let(:field_hierarchy) { %i[some random fields] }
        let(:options) { { field_hierarchy: field_hierarchy, field_policy: Porridge::FieldPolicy.new } }
        let(:results) { execute(options: options) }

        it 'adds the field name' do
          expect(results[:options][:field_hierarchy]).to eq %i[some random fields field_name]
        end

        it 'does not change the original options hash' do
          expect { results }.not_to(change { options })
        end
      end
    end
  end
end
