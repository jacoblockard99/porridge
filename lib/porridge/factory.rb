# frozen_string_literal: true

module Porridge
  # {Factory} is a class that is capable of instantiating various porridge serializers and extractors. All extractor-
  # creation methods are suffixed with +_extractor+, all serializer-creation methods are suffixed with +_serializer+,
  # and all field serializer-creation methods are suffixed with +_field_serializer+.
  #
  # You may subclass this class if you wish to change its behavior. For example, if you wished to substitute your
  # own "from name" extractor, that accesses a hash value rather than sends a method call, for the default one:
  #
  #   class CustomPorridgeFactory < Porridge::Factory
  #     def from_name_extractor(name)
  #       extractor HashValueExtractor.new(name)
  #     end
  #   end
  #
  # {#from_name_field_serializer}, {#attribute_extractor}, and {#attribute_field_serializer} would then be automatically
  # updated in the process, along with any other methods that depend on the aforementioned ones.
  #
  # This method is rarely used directly. Typically, it is used in conjunction with a {SerializerDefiner} and/or
  # {SerializerDefinition} instance.
  class Factory
    def extractor(base)
      return nil if base.nil?

      Extractor.ensure_valid!(base)
      base
    end

    def from_name_extractor(name)
      extractor SendExtractor.new(name)
    end

    def custom_extractor(callback)
      extractor callback
    end

    def association_extractor(serializer:, extractor: nil, extraction_name: nil, callback: nil, &block)
      extractor SerializingExtractor.new(
        extractor || custom_extractor(callback) || custom_extractor(block) || from_name_extractor(extraction_name),
        serializer
      )
    end

    def belongs_to_extractor(...)
      association_extractor(...)
    end

    def has_many_extractor(...)
      association_extractor(...)
    end

    def serializer(base)
      return nil if base.nil?

      Serializer.ensure_valid!(base)
      base
    end

    def chain_serializer(*bases)
      serializer ChainSerializer.new(*bases)
    end

    def serializers(...)
      chain_serializer(...)
    end

    def for_extracted_serializer(serializer, extractor)
      serializer SerializerForExtracted.new(serializer, extractor)
    end

    def serializer_for_extracted(...)
      for_extracted_serializer(...)
    end

    def field_serializer(name, extractor)
      serializer FieldSerializer.new(name, extractor)
    end

    def attribute_field_serializer(name, callback = nil, extraction_name: nil, &block)
      extractor = custom_extractor(callback || block) || from_name_extractor(extraction_name || name)
      field_serializer(name, extractor)
    end

    def association_field_serializer(name, options = {}, &block)
      options[:extraction_name] ||= name
      field_serializer(name, association_extractor(**options, &block))
    end

    def belongs_to_field_serializer(...)
      association_field_serializer(...)
    end

    def has_many_field_serializer(...)
      association_field_serializer(...)
    end
  end
end
