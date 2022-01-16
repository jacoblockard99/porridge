# frozen_string_literal: true

module Porridge
  # {SendExtractor} is an extractor that retrieves a value from an object by simply calling a predefined method on it.
  class SendExtractor < Extractor
    # Creates a new instance of {SendExtractor} with the given method name.
    # @param method_name [String, Symbol] the name of the method to call when extracting the value.
    def initialize(method_name)
      @method_name = method_name.to_s
      super()
    end

    # Extracts the value from the given object by sending the method name ({#method_name}) to it.
    # @param object the object from which to retrieve the value.
    # @param _options [Hash] a hash of "options," which may be application-specific. These options are ignored.
    # @return the extracted value, as returned from the sent method.
    def call(object, _options)
      object.respond_to?(method_name) ? object.send(method_name) : nil
    end

    private

    # The name of the method to call when extracting the value.
    # @return [String]
    attr_reader :method_name
  end
end
