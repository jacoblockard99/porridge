# frozen_string_literal: true

module Porridge
  # {Serializer} is the nominal base class for all porridge serializers.
  #
  # A serializer is an object that arbitrarily transforms a given input for a given object with a given set of options.
  # The input may be anything, but is typically either a hash or an array. In Rails applications, the object is often
  # an ActiveRecord model. The options may be application-specific.
  #
  # Serializers are the heart and soul of the porridge gem and are typically layered with composition into a final
  # serializer that is used to actually serialize an object into (typically) a hash or array. Thus, a serializer often
  # simply wraps another serializer, transforming the object or options in some way.
  #
  # You are encouraged, but not required, to have all your serializers derive from this class. Currently, any object
  # that implements the +#call+ method is a valid serializer.
  class Serializer
    # Determines whether the given object is a valid porridge serializer. Currently, any object that responds to the
    # '#call' method is valid.
    # @param object the object to check.
    # @return [Boolean] +true+ if the object is a valid serializer; +false+ otherwise.
    def self.valid?(object)
      object.respond_to? :call
    end

    # Ensures that all the provided objects are valid serializers, raising {InvalidSerializerError} if not.
    # @param objects [Array] the splatted array of objects to validate.
    # @return [Boolean] +true+ if all the objects were valid; raises an error otherwise.
    # @raise [InvalidSerializerError] if any of the provided objects are not valid serializers.
    def self.ensure_valid!(*objects)
      objects.each { |object| raise InvalidSerializerError unless valid?(object) }
      true
    end

    # Should transforms the given input for the given object with the given options and return the desired output.
    # @param _object the object for which to transform the input.
    # @param input the object being transformed, typically either a hash or an array.
    # @param _options [Hash] a hash of "options," which may be application specific.
    # @return the transformed output, typically either a hash or an array.
    def call(_object, input, _options)
      input
    end
  end
end
