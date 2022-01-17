# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string/inflections'

module Porridge
  # {SerializerWithRoot} is a serializer that wraps another serializer and adds a "root key" to the resulting hash.
  class SerializerWithRoot < Serializer
    # Creates a new instance of {SerializerWithRoot} with the given base serializer and, optionally, root key.
    # @param base [Serializer, #call] the base serializer to wrap.
    # @param root_key the "root" key to inject into the resulting hash. If +nil+, which is the default, the root key
    #   will be inferred from the object.
    # @raise [InvalidSerializerError] if the provided base serializer is not a valid serializer.
    def initialize(base, root_key: nil)
      Serializer.ensure_valid!(base)
      @base = base
      @root_key = root_key
      super()
    end

    # Serializes the given input for the given object with the given options by delegating to the base serializer
    # ({#base}) and adding a root key to the resulting hash. Note that the output of the base serializer *must* be a
    # hash.
    #
    # If the root key was not set manually, it will be inferred from the "underscored" class name of the object. If the
    # object is an array (according to {#array?}), then the class name will be derived from the first object in the
    # array, and will be pluralized. Be aware that retrieving the first element of the "array" may cause an SQL query to
    # be performed if the "array" is a Rails relation.
    #
    # Note that an inferred root key is always a string. You may wish to use a {KeyNormalizingSerializer} if symbol
    # keys are desired.
    #
    # @param object the object for which to transform the input. If no root key was set manually, it will be inferred
    #   from the object's class.
    # @param input the object being transformed, typically either a hash or an array.
    # @param options [Hash] a hash of "options," which may be application specific.
    # @return [Hash] the hash returned from the base serializer, injected with a root key.
    def call(object, input, options)
      { evaluate_root_key(object) => base.call(object, input, options) }
    end

    protected

    # Determines whether the given object functions like an array for the purposes of this {SerializerWithRoot}. The
    # default implementation checks to see whether the object implements both +#map+ and +#first+. You may override the
    # default behavior by overriding this method. Note that if you override {ArraySerializer#like_array?} you will
    # likely wish to override this method as well.
    # @param object the object to check.
    # @return [Boolean] +true+ if the given object is like an array; +false+ otherwise.
    def array?(object)
      object.respond_to?(:map) && object.respond_to?(:first)
    end

    private

    # Gets a root key for the given object by either returning {#root_key}, or returning a singular/plural version
    # of the {#base_root_key}, depending on whether the object is an array.
    # @param object the object for which to get a root key.
    # @return the resolved string root key.
    def evaluate_root_key(object)
      return root_key if root_key

      array?(object) ? base_root_key(object).pluralize : base_root_key(object).singularize
    end

    # Gets the inferred base root key, without singularization or pluralization for the given object.
    # @param object the object for which to get the base root key.
    # @return [String] the resolved base root key.
    def base_root_key(object)
      representative_sample(object).class.name.underscore.to_s
    end

    # Gets a "representative" sample from the given object. In practice, this means either returning the object itself,
    # or, if the object is an array-like structure, returning the first element.
    def representative_sample(object)
      array?(object) ? object.first : object
    end

    # The base serializer to wrap.
    # @return [Serializer, #call]
    attr_reader :base

    # The explicit root key; if +nil+, will be inferred.
    attr_reader :root_key
  end
end
