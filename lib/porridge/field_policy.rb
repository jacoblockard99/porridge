# frozen_string_literal: true

module Porridge
  # {FieldPolicy} is the nominal base class for all field policy classes.
  #
  # A field policy is an object that is capable of determining whether a certain "field" is allowed in a given
  # context. Currently, it is primarily used in {FieldSerializer} as the default method of determining whether a field
  # is valid. You are encouraged, but not required, to have your own custom field policies derive from this class.
  # Currently, any object that implements the +#allowed?+ method is a valid field policy.
  class FieldPolicy
    # Determines whether the given object is a valid porridge field policy. Currently, any object that responds to the
    # +#allowed?+ method is valid.
    # @param object the object to check.
    # @return [Boolean] +true+ if the object is a valid field policy; +false+ otherwise.
    def self.valid?(object)
      object.respond_to? :allowed?
    end

    # Ensures that all the provided objects are valid field policies, raising {InvalidFieldPolicyError} if not.
    # @param objects [Array] the splatted array of objects to validate.
    # @return [Boolean] +true+ if all the objects were valid; raises an error otherwise.
    # @raise [InvalidFieldPolicyError] if any of the provided objects are not valid field policies.
    def self.ensure_valid!(*objects)
      objects.each { |object| raise InvalidFieldPolicyError unless valid?(object) }
      true
    end

    # Determiners whether the field with the given name for the given object with the given options is currently
    # allowed.
    # @param _name the name of the field being validated.
    # @param _object the object for which the field being validated is being generated.
    # @param _options [Hash] the options with which the field being validated is being generated.
    # @return [Boolean] +true+ if the indicated field is allowed; +false+ otherwise.
    def allowed?(_name, _object, _options)
      true
    end
  end
end
