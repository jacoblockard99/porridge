# frozen_string_literal: true

module Porridge
  # {InvalidFieldPolicyError} is the error that is thrown when a non-field-policy object is used like a field policy.
  class InvalidFieldPolicyError < Error; end
end
