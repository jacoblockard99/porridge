# frozen_string_literal: true

module Porridge
  # {ArraySerializer} is a serializer that wraps another serializer, calling it for every element of the input array,
  # if an array was given, or simply passing it the input if not.
  class ArraySerializer < Serializer
    # Creates a new instance of {ArraySerializer} with the given base serializer.
    # @param base [Serializer, #call] the base serializer to call for any input, or all elements of that input if the
    #   input is an array.
    # @raise [InvalidSerializerError] if the given base serializer is not a valid serializer.
    def initialize(base)
      Serializer.ensure_valid!(base)
      @base = base
      super()
    end

    # Serializes the given object, which may be an array, for the given input with the given options. If the object
    # is an array (according to {#array?}), the base serializer {#base} will be called for each element, and an array
    # with each result will be returned. If the object is not an array, will simply delegate to {#base}.
    #
    # The given object and options will be given to the base serializer for every element. Note that the options are
    # *not* cloned or duplicated. Therefore <b>the base serializer must not mutate the options object</b> or else
    # the other invocations will also receive the mutated version.
    #
    # @param object_or_objects [Object, Array<Object>] the object or array of objects for which to transform the input.
    # @param input the object being transformed, typically either a hash or an array.
    # @param options [Hash] a hash of "options," which may be application specific.
    # @return [Object, Array<Object>] the transformed output if the object was not an array, or an array of all
    #   transformed outputs if the object was an array.
    def call(object_or_objects, input, options)
      if array?(object_or_objects)
        object_or_objects.map { |object| base.call(object, input, options) }
      else
        base.call(object_or_objects, input, options)
      end
    end

    protected

    # Determines whether the given object is an array for the purposes of this {ArraySerializer} instance. The default
    # implementation simple checks to see if the object implements the +map+ method. You may override this method to
    # change the default behavior, if, for example, you have a non-array that implements +map+.
    # @param object the object to check.
    # @return [Boolean] +true+ if the given object functions like an array; +false+ if otherwise.
    def array?(object)
      object.is_a? Array
    end

    private

    # The base serializer, which will be called for the object, or each object, if an array is given.
    # @return [Serializer, #call]
    attr_reader :base
  end
end
