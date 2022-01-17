# frozen_string_literal: true

module Porridge
  # {ChainSerializer} is a serializer that chains multiple other serializers together by passing the output of the
  # first one as the input of the second, and the output of the second as the input of the third, and so on.
  class ChainSerializer < Serializer
    # Creates a new instance of {ChainSerializer} with the given serializers to chain.
    # @param serializers [Array<Serializer,#call>] the splatted array of serializers to chain.
    # @raise [InvalidSerializerError] if any of the given serializers are not valid serializers.
    def initialize(*serializers)
      super()
      Serializer.ensure_valid!(*serializers)
      @serializers = serializers
    end

    # Transforms the given input for the given object with the given options by chaining each serializer (contained in
    # {#serializers}). The provided input will be given to the first serializer, whose output will be given to the next
    # serializer, and so on for each serializer.
    #
    # The given object and options will be given to all the provided serializers. Note that the options are *not*
    # cloned or duplicated. Therefore <b>none of the serializers should mutate the options object</b> or else
    # all the other serializers will also receive the mutated version.
    #
    # @param object the object for which to transform the input.
    # @param input the object being transformed, typically either a hash or an array.
    # @param options [Hash] a hash of "options," which may be application specific.
    # @return the transformed output, typically either a hash or an array, as returned from the final chained
    #   serializer.
    def call(object, input, options)
      output = input
      serializers.each { |serializer| output = serializer.call(object, output, options) }
      output
    end

    private

    # The array of chained serializers.
    # @return [Array<Serializer, #call>]
    attr_reader :serializers
  end
end
