# frozen_string_literal: true

module Porridge
  # {InvalidExtractorError} is the error that is thrown when a non-extractor object is used like an extractor.
  class InvalidExtractorError < Error; end
end
