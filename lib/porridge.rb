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
require_relative 'porridge/invalid_field_policy_error'
require_relative 'porridge/field_policy'
require_relative 'porridge/field_serializer'
require_relative 'porridge/serializing_extractor'
require_relative 'porridge/whitelist_field_policy'
require_relative 'porridge/factory'

# {Porridge} is the root namespace for all classes in the +porridge+ gem.
module Porridge; end
