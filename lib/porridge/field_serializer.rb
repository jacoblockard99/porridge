# frozen_string_literal: true

module Porridge
  # {FieldSerializer} is a serializer that adds a "field" to a hash. It does so by using a predefined "field name" as
  # the key and evaluates an {Extractor} for the object for the value.
  #
  # {FieldSerializer} is the most opinionated piece of the porridge framework. In particular, it adds to a
  # +:field_hierarchy+ array in the options hash to keep track of nested fields. It also requires the use of a
  # {FieldPolicy} object given in the options to determine whether a given field is allowed. Do not be afraid to
  # subclass {FieldSerializer} or even create a new "field serializer" class altogether if you want to substantially
  # change the way fields are implemented.
  class FieldSerializer < Serializer
    # Creates a new instance of {FieldSerializer} with the given field name and value extractor.
    # @param name the name of the field; will be used as the key for the field in the hash.
    # @param extractor [Extractor, #call] the value extractor to use to retrieve a value from the object, which will be
    #   used as the value for the field in the hash.
    # @raise [InvalidExtractorError] if the provided extractor is not a valid extractor.
    def initialize(name, extractor)
      @name = name
      @extractor = extractor
      Extractor.ensure_valid!(extractor)
      super()
    end

    # Serializes the given input hash for the given object with the given options by adding an element to the hash with
    # a key that is equal to the field name ({#name}) and a value extracted from the object using the field extractor
    # ({#extractor}).
    # @param object the object for which to transform the input. The field value will be retrieved from this object
    #   using the extractor.
    # @param hash [Hash] the input hash being transformed. A key-value pair will be added for the field.
    # @param options [Hash] a hash of "options," which may be application specific.
    # @option options [FieldPolicy, #allowed?] :field_policy the field policy to use to determine whether the field
    #   is currently allowed. This option *must* be provided.
    # @return [Hash] the transformed hash.
    # @raise [InvalidFieldPolicyError] if no field policy was provided or if the field policy was not a valid field
    #   policy object.
    def call(object, hash, options)
      if allowed?(object, options)
        options = options.dup
        add_field_to_hierarchy!(options)
        hash_with_field(object, hash, options)
      else
        hash
      end
    end

    private

    # Determines whether the given object/options, along with the current {#name} constitutes a valid field. Currently,
    # this is done by simply delegating to the field policy which should have been provided as an option.
    # @param object the object for which the field being validated is being implemented.
    # @param options [Hash] the options for which the field being validated is being implemented.
    # @return [Boolean] +true+ if the indicated field is valid; +false+ otherwise.
    # @raise [InvalidFieldPolicyError] if no field policy was provided or if the field policy was not a valid field
    #   policy object.
    def allowed?(object, options)
      FieldPolicy.ensure_valid!(options[:field_policy])
      options[:field_policy].allowed?(name, object, options.except(:field_policy))
    end

    # Safely adds the current {#name} to the +:field_hierarchy+ in the given options hash. While the options hash itself
    # is mutated, the field hierarchy array is first duplicated, meaning the options hash must have first been
    # duplicated for this to be safe.
    # @param options_hash [Hash] the options hash to which the field should be added.
    # @return [void]
    def add_field_to_hierarchy!(options_hash)
      options_hash[:field_hierarchy] ||= []
      options_hash[:field_hierarchy] = options_hash[:field_hierarchy].dup
      options_hash[:field_hierarchy] << name
    end

    # Creates a new hash from the given one with a field for the given object injected.
    # @param object the object for which to inject the field. Will be passed to the extractor.
    # @param hash [Hash] the hash into which to inject the field.
    # @param options [Hash] the options for which to inject the field. Will be passed to the extractor.
    # @return [Hash] the transformed hash.
    def hash_with_field(object, hash, options)
      hash.merge(name => extractor.call(object, options))
    end

    # The name of the field being serialized by this {FieldSerializer}; used as the key for the field in the hash.
    attr_reader :name

    # The value extractor to use to retrieve a value from the object for which serialization is occurring.
    # @return [Extractor, #call]
    attr_reader :extractor
  end
end
