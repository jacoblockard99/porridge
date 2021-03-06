# frozen_string_literal: true

module Porridge
  # {Extractor} is the nominal base class for all porridge value extractors.
  #
  # A (value) extractor is an object that is capable of retrieving a value from an object, given a set of "options",
  # which may be application-specific. You are encouraged, but not required, to have your extractors derive from this
  # class. Currently, any object that implements a +#call+ method is a valid extractor.
  class Extractor
    # Determines whether the given object is a valid porridge extractor. Currently, any object that responds to the
    # +#call+ method is valid.
    # @param object the object to check.
    # @return [Boolean] +true+ if the object is a valid extractor; +false+ otherwise.
    def self.valid?(object)
      object.respond_to? :call
    end

    # Ensures that all the provided objects are valid extractors, raising {InvalidExtractorError} if not.
    # @param objects [Array] the splatted array of objects to validate.
    # @return [Boolean] +true+ if all the objects were valid; raises an error otherwise.
    # @raise [InvalidExtractorError] if any of the provided objects are not valid extractors.
    def self.ensure_valid!(*objects)
      objects.each { |object| raise InvalidExtractorError unless valid?(object) }
      true
    end

    # Should extract a value from the given object with the given options. Subclasses should override this method.
    # @param object the object from which to retrieve the value.
    # @param options [Hash] a hash of "options," which may be application-specific.
    # @return the extracted value.
    def call(object, options); end
  end
end
