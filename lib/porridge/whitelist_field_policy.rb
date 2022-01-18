# frozen_string_literal: true

module Porridge
  # {WhitelistFieldPolicy} is a field policy that uses a nested whitelist of field names to determine which fields are
  # valid.
  class WhitelistFieldPolicy < FieldPolicy
    # Creates a new instance of {WhitelistFieldPolicy} with the given whitelist.
    # @param whitelist [Hash] the nested whitelist hash of allowed field names.
    def initialize(whitelist)
      @whitelist = whitelist
      super()
    end

    # Determiners whether the field with the given name with the given options is currently allowed by checking the
    # field hierarchy, which must be contained in +options[:field_hierarchy] against the whitelist.
    # @param name the name of the field being validated.
    # @param _object the object for which the field being validated is being generated.
    # @param options [Hash] the options with which the field being validated is being generated.
    # @return [Boolean] +true+ if the indicated field is allowed; +false+ otherwise.
    def allowed?(name, _object, options)
      field_hierarchy = options[:field_hierarchy] || []
      _allowed?([*field_hierarchy, name], whitelist)
    end

    protected

    # Determines whether the given object functions as a hash for the purposes of this {WhitelistFieldPolicy} instance.
    # You may override this method if desired, but hashes must at least respond to +#[]+.
    # @param input the input object to check.
    # @return [Boolean] +true+ if the given object is like a hash; +false+ otherwise.
    def hash?(input)
      input.is_a? Hash
    end

    private

    # @overload _allowed?(field_hierarchy, whitelist)
    #   Recursively traverses the given field hierarchy and determines whether the field indicated by the hierarchy is
    #   allowed for the given whitelist.
    #   @param field_hierarchy [Array] the field hierarchy to validate.
    #   @param whitelist [Hash] the nested whitelist hash of field names.
    # @overload _allowed?(field_hierarchy, whitelist, level)
    #   Recursively traverses the given field hierarchy and determines whether the field indicated by the hierarchy is
    #   allowed for the given whitelist, starting from the specified level.
    #   @param field_hierarchy [Array] the field hierarchy to validate.
    #   @param whitelist [Hash] the nested whitelist hash of field names.
    #   @param level [Integer] the current level of the hierarchy being checked.
    def _allowed?(field_hierarchy, whitelist, level = 0)
      # If the level is equal to the field hierarchy length, then we've reached the end. Immediately return the
      # truthiness of whitelist, which is now equal to the final resolved value referenced by the field hierarchy.
      return !!whitelist if level >= field_hierarchy.count

      # If the current whitelist is not a hash, then the field hierarchy is deeper than the whitelist.
      # As an example, take this whitelist:
      #   { users: true }
      # And this field hierarchy:
      #   [:user, :id]
      # One interpretation of this is that since 'users' is true, all fields should be allowed. We take the opposite
      # approach and say that no attributes have been explicitly defined.
      # Therefore immediately return false.
      return false unless hash?(whitelist)

      _allowed?(field_hierarchy, whitelist[field_hierarchy[level]], level + 1)
    end

    # The nested whitelist hash of field names.
    # @return [Hash]
    attr_reader :whitelist
  end
end
