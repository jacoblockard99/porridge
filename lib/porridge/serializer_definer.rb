# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/module/delegation'

module Porridge
  # {SerializerDefiner} is a class that wraps a {Factory} and allows serializes to be easily defined with an elegant
  # DSL.
  class SerializerDefiner
    FACTORY_PREFIX = 'create_'
    SERIALIZER_SUFFIX = '_serializer'
    FIELD_SERIALIZER_SUFFIX = '_field_serializer'

    delegate :call, to: :defined_serializer

    def initialize(factory = Factory.new)
      @factory = factory
      @serializers = []
    end

    def method_missing(method_name, *args, &block)
      method_name = method_name.to_s
      return factory.send(method_name.delete_prefix(FACTORY_PREFIX), *args, &block) if create_method? method_name

      if serializer_method? method_name
        return add_serializer(factory.send(method_name + SERIALIZER_SUFFIX, *args, &block))
      end

      if field_serializer_method? method_name
        return add_serializer(factory.send(method_name + FIELD_SERIALIZER_SUFFIX, *args, &block))
      end

      super(method_name.to_sym, *args, &block)
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name = method_name.to_s
      super(method_name.to_sym, include_private) ||
        create_method?(method_name) ||
        serializer_method?(method_name) ||
        field_serializer_method?(method_name)
    end

    def defined_serializer
      factory.serializers(*added_serializers)
    end

    def added_serializers
      @serializers
    end

    def serializer(...)
      add_serializer(factory.serializer(...))
    end

    private

    def create_method?(method_name)
      method_name.start_with?(FACTORY_PREFIX) && factory.respond_to?(method_name.delete_prefix(FACTORY_PREFIX))
    end

    def serializer_method?(method_name)
      factory.respond_to?(method_name + SERIALIZER_SUFFIX)
    end

    def field_serializer_method?(method_name)
      factory.respond_to?(method_name + FIELD_SERIALIZER_SUFFIX)
    end

    def add_serializer(serializer)
      @serializers << serializer
    end

    attr_reader :factory
  end
end
