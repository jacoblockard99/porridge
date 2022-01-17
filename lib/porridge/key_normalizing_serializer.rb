# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/hash/keys'

module Porridge
  # {KeyNormalizingSerializer} is a serializer that wraps another serializer and recursively normalizes the keys of the
  # resulting hash to either strings or symbols.
  class KeyNormalizingSerializer < Serializer
    # Creates a new instance of {KeyNormalizingSerializer} with the given base serializer and key type.
    # @param base [Serializer, #call] the base serializer to wrap. Note that the output of the base serializer *must*
    #   be a hash.
    # @param key_type [Symbol] the type that the keys should be normalized to. Both +:string+ and +:symbol+ are
    #   supported.
    # @raise [InvalidSerializerError] if the given base serializer is not a valid serializer.
    def initialize(base, key_type: :string)
      Serializer.ensure_valid!(base)
      @base = base
      @key_type = key_type
      super()
    end

    # Serializes the given input for the given object with the given options by delegating to the base serializer
    # ({#base}) and recursively transforming the keys of the resulting hash to the appropriate type ({#key_type}).
    # Note that the output of the base serializer *must* be a hash.
    # @param object the object for which to transform the input.
    # @param input the object being transformed, typically either a hash or an array.
    # @param options [Hash] a hash of "options," which may be application specific.
    # @return [Hash] the hash returned from the base serializer, normalized.
    def call(object, input, options)
      normalize_keys(base.call(object, input, options))
    end

    private

    # Normalizes the keys of the given hash according to the {#key_type}. Uses ActiveSupport methods to accomplish this.
    # @param hash [Hash] the hash to normalize.
    # @return [Hash] the normalized hash.
    def normalize_keys(hash)
      case key_type
      when :string
        hash.deep_stringify_keys
      when :symbol
        hash.deep_symbolize_keys
      else
        input
      end
    end

    # The base serializer whose output hash will be normalized
    # @return [Serializer, #call]
    attr_reader :base

    # The key type that the hash should be normalized to.
    # @return [Symbol] either +:string+ or +:symbol+.
    attr_reader :key_type
  end
end
