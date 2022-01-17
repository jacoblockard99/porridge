# frozen_string_literal: true

require 'spec_helper'

class SomeRandomClass; end

class OverridenSerializerWithRoot < Porridge::SerializerWithRoot
  protected

  def array?(_object)
    false
  end
end

describe Porridge::SerializerWithRoot do
  describe '.new' do
    def execute(serializer:)
      described_class.new(serializer)
    end

    it_behaves_like 'a method requiring a valid serializer'
  end

  describe '#call' do
    let(:base) do
      proc do |obj, input, opts|
        {
          some: {
            random: true,
            'hash' => true
          },
          object: obj,
          input: input,
          opt: opts[:opt]
        }
      end
    end

    context 'with explicit symbol root key' do
      shared_examples 'a valid result' do |object|
        it 'wraps the hash with a string, delegating appropriately' do
          expect(result).to eq({
            manual_key: {
              some: {
                random: true,
                'hash' => true
              },
              object: object,
              input: 'input',
              opt: 'option'
            }
          })
        end
      end

      context 'with a non-array object' do
        let(:instance) { described_class.new(base, root_key: :manual_key) }
        let(:result) { instance.call('object', 'input', opt: 'option') }

        it_behaves_like 'a valid result', 'object'
      end

      context 'with an array object' do
        let(:instance) { described_class.new(base, root_key: :manual_key) }
        let(:result) { instance.call(%w[object object], 'input', opt: 'option') }

        it_behaves_like 'a valid result', %w[object object]
      end
    end

    context 'with explicit string root key' do
      shared_examples 'a valid result' do |object|
        it 'wraps the hash with a string, delegating appropriately' do
          expect(result).to eq({
            'manual_key' => {
              some: {
                random: true,
                'hash' => true
              },
              object: object,
              input: 'input',
              opt: 'option'
            }
          })
        end
      end

      context 'with a non-array object' do
        let(:instance) { described_class.new(base, root_key: 'manual_key') }
        let(:result) { instance.call('object', 'input', opt: 'option') }

        it_behaves_like 'a valid result', 'object'
      end

      context 'with an array object' do
        let(:instance) { described_class.new(base, root_key: 'manual_key') }
        let(:result) { instance.call(%w[object object], 'input', opt: 'option') }

        it_behaves_like 'a valid result', %w[object object]
      end

    end

    context 'with implicit root key' do
      let(:instance) { described_class.new(base) }

      context 'with a non-array object' do
        let(:result) { instance.call(SomeRandomClass.new, Object.new, {}) }

        it 'infers from the class name', :aggregate_failures do
          expect(result.count).to eq 1
          expect(result.key?('some_random_class')).to eq true
        end
      end

      context 'with an array object' do
        let(:result) { instance.call([SomeRandomClass.new, Object.new], Object.new, {}) }

        it 'infers from the pluralized first class name', :aggregate_failures do
          expect(result.count).to eq 1
          expect(result.key?('some_random_classes')).to eq true
        end

        context 'with array? overriden' do
          let(:instance) { OverridenSerializerWithRoot.new(base) }
          let(:result) { instance.call([SomeRandomClass.new, Object.new], Object.new, {}) }

          it 'infers from the object class name', :aggregate_failures do
            expect(result.count).to eq 1
            expect(result.key?('array')).to eq true
          end
        end
      end
    end
  end
end
