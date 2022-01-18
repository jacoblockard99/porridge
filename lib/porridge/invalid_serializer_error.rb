# frozen_string_literal: true

module Porridge
  # {InvalidSerializerError} is the error that is thrown when a non-serializer object is used like a serializer.
  class InvalidSerializerError < Error; end
end
