# frozen_string_literal: true

require_relative 'porridge/version'
require_relative 'porridge/extractor'
require_relative 'porridge/send_extractor'
require_relative 'porridge/serializer'

module Porridge
  class Error < StandardError; end
end
