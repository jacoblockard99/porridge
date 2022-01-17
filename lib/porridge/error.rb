# frozen_string_literal: true

module Porridge
  # {Error} is the base class for all porridge-related errors. You may thus catch {Error} to catch all porridge-specific
  # errors.
  class Error < StandardError
  end
end
