# frozen_string_literal: true

module Porridge
  # {SerializingExtractor} is an extractor that wraps another extractor and serializes for its output using a provided
  # serializer. Note that {SerializingExtractor} passes the output of the base extractor as the *object* for the
  # serializer, not the input.
  class SerializingExtractor < Extractor
    # Creates a new instance of {SerializingExtractor} with the given base extractor and serializer.
    # @param base [Extractor, #call] the extractor to wrap, whose output will be serialized for before being returned.
    # @param serializer [Serializer, #call] the serializer to use to transform the output of the extractor.
    # @raise [InvalidExtractorError] if the provided base extractor was not a valid extractor.
    # @raise [InvalidSerializerError] if the provided serializer was not a valid serializer.
    def initialize(base, serializer)
      Extractor.ensure_valid!(base)
      Serializer.ensure_valid!(serializer)
      @base = base
      @serializer = serializer
      super()
    end

    # Extracts a value from the given object for the given options by:
    #   1. Using the base extractor ({#extractor}) to extract a value from the object with the given options; and
    #   2. Passing that value as the object to {#serializer#call}. A blank hash is given as the input, and the
    #      given options are passed along.
    # @param object the object from which to retrieve the value.
    # @param options [Hash] a hash of "options," which may be application-specific.
    # @return the extracted value.
    def call(object, options)
      serializer.call(base.call(object, options), {}, options)
    end

    private

    # The base extractor.
    # @return [Extractor, #call]
    attr_reader :base

    # The serializer to use to serialize for the output of the base extractor.
    # @return [Serializer, #call]
    attr_reader :serializer
  end
end
