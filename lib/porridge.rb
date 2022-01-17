# frozen_string_literal: true

require_relative 'porridge/version'
require_relative 'porridge/extractor'
require_relative 'porridge/send_extractor'
require_relative 'porridge/serializer'
require_relative 'porridge/chain_serializer'
require_relative 'porridge/array_serializer'
require_relative 'porridge/key_normalizing_serializer'
require_relative 'porridge/serializer_for_extracted'
require_relative 'porridge/serializer_with_root'
require_relative 'porridge/error'
require_relative 'porridge/invalid_serializer_error'
require_relative 'porridge/invalid_extractor_error'

module Porridge; end
