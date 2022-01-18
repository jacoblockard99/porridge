# frozen_string_literal: true

module Porridge
  # {SerializerForExtracted} is a serializer that wraps another serializer and passes it an object that is extracted
  # from the initial object using an {Extractor}.
  class SerializerForExtracted < Serializer
    # Creates a new instance of {SerializerForExtracted} with the given base serializer and extractor.
    # @param base [Serializer, #call] the base serializer to wrap.
    # @param extractor [Extractor, #call] the extractor to use to extract a value from the object before passing it
    #   to the base serializer.
    # @raise [InvalidSerializerError] if the provided base serializer is not a valid serializer.
    # @raise [InvalidExtractorError] if the provided extractor is not a valid extractor.
    def initialize(base, extractor)
      Serializer.ensure_valid!(base)
      Extractor.ensure_valid!(extractor)
      @base = base
      @extractor = extractor
      super()
    end

    # Serializes the given input for the given object with the given options by first extracted a value from the given
    # object, then passing that value, along with the given input and options, to the base serializer ({#base}).
    # @param object the object for which to transform the input. A value will be extracted and that value will be passed
    #   to the base serializer.
    # @param input the object being transformed, typically either a hash or an array.
    # @param options [Hash] a hash of "options," which may be application specific.
    # @return the transformed output, typically either a hash or an array, as returned from the base serializer.
    def call(object, input, options)
      extracted_value = extractor.call(object, options)
      base.call(extracted_value, input, options)
    end

    private

    # The base serializer to wrap.
    # @return [Serializer, #call]
    attr_reader :base

    # The extractor to use to extract a value from the object before passing it to the base serializer.
    # @return [Extractor, #call]
    attr_reader :extractor
  end
end
