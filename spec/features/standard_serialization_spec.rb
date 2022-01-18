# frozen_string_literal: true

require 'spec_helper'

class SerializerWithRoot < Porridge::SerializerWithRoot
  protected

  def array?(object)
    super && !object.is_a?(Struct)
  end
end

class ArraySerializer < Porridge::ArraySerializer
  protected

  def array?(object)
    super && !object.is_a?(Struct)
  end
end

Person = Struct.new(:identifier, :name, :sex, :associations, keyword_init: true)
PersonAssociationList = Struct.new(:buildings, keyword_init: true)
Building = Struct.new(:identifier, :location, :city, keyword_init: true)

describe 'standard serialization scenarios' do
  let(:serializer) do
    Porridge::KeyNormalizingSerializer.new(
      SerializerWithRoot.new(
        ArraySerializer.new(
          Porridge::ChainSerializer.new(
            Porridge::FieldSerializer.new(:id, Porridge::SendExtractor.new(:identifier)),
            Porridge::FieldSerializer.new(:name, Porridge::SendExtractor.new(:name)),
            Porridge::FieldSerializer.new(:gender, Porridge::SendExtractor.new(:sex)),
            Porridge::FieldSerializer.new(
              :buildings,
              Porridge::SerializingExtractor.new(
                proc { |obj| obj.associations.buildings },
                ArraySerializer.new(
                  Porridge::ChainSerializer.new(
                    Porridge::FieldSerializer.new(:id, Porridge::SendExtractor.new(:identifier)),
                    Porridge::FieldSerializer.new(:location, Porridge::SendExtractor.new(:location)),
                    Porridge::FieldSerializer.new(:city, proc { |obj| "#{obj.city}, United States" }),
                    Porridge::FieldSerializer.new(:type, proc { 'good' })
                  )
                )
              )
            )
          )
        )
      )
    )
  end

  describe 'basic standard scenario' do
    let(:object) do
      Person.new(
        identifier: 123,
        name: 'Jacob Lockard',
        sex: 'male',
        associations: PersonAssociationList.new(
          buildings: [
            Building.new(
              identifier: 456,
              location: 'At the Cross',
              city: 'Harrisonburg'
            ),
            Building.new(
              identifier: 789,
              location: 'Wherever I Want',
              city: 'Staunton'
            ),
            Building.new(
              identifier: 101,
              location: 'On A Hill',
              city: 'Anchorage'
            )
          ]
        )
      )
    end
    let(:policy) do
      Porridge::WhitelistFieldPolicy.new({
        id: true,
        name: true,
        gender: false,
        sex: true,
        associations: false,
        buildings: {
          id: true,
          location: true,
          city: true
        }
      })
    end
    let(:result) do
      serializer.call(object, {}, field_policy: policy)
    end

    it 'correctly serializes' do
      expect(result).to eq({
        'person' => {
          'id' => 123,
          'name' => 'Jacob Lockard',
          'buildings' => [
            {
              'id' => 456,
              'location' => 'At the Cross',
              'city' => 'Harrisonburg, United States'
            },
            {
              'id' => 789,
              'location' => 'Wherever I Want',
              'city' => 'Staunton, United States'
            },
            {
              'id' => 101,
              'location' => 'On A Hill',
              'city' => 'Anchorage, United States'
            }
          ]
        }
      })
    end
  end

  describe 'scenario with multiple objects' do
    let(:object) do
      [
        Person.new(
          identifier: nil,
          sex: 'female',
          associations: PersonAssociationList.new(
            buildings: [
              Building.new(
                identifier: 456,
                location: 'At the Cross',
                city: 'Harrisonburg'
              )
            ]
          )
        ),
        Person.new(
          identifier: 100,
          sex: 'male',
          name: 'Jacob',
          associations: PersonAssociationList.new(
            buildings: [
              Building.new(
                identifier: 789,
                location: 'The Desk',
                city: 'Virginia Beach'
              )
            ]
          )
        )
      ]
    end
    let(:policy) do
      Porridge::WhitelistFieldPolicy.new({
        name: true,
        gender: true,
        buildings: {
          location: true,
          city: true,
          type: true
        }
      })
    end
    let(:result) do
      serializer.call(object, {}, field_policy: policy)
    end

    it 'correctly serializes' do
      expect(result).to eq({
        'people' => [
          {
            'name' => nil,
            'gender' => 'female',
            'buildings' => [
              {
                'location' => 'At the Cross',
                'city' => 'Harrisonburg, United States',
                'type' => 'good'
              }
            ]
          },
          {
            'name' => 'Jacob',
            'gender' => 'male',
            'buildings' => [
              {
                'location' => 'The Desk',
                'city' => 'Virginia Beach, United States',
                'type' => 'good'
              }
            ]
          }
        ]
      })
    end
  end
end
