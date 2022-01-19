# frozen_string_literal: true

module Porridge
  # {SerializerDefinition} is a class that allows serializers to be defined as with a {SerializerDefiner}, but within
  # a class. Simply subclass this class and use the same DSL within it.
  class SerializerDefinition
    class << self
      attr_writer :definer

      delegate_missing_to :definer

      def inherited(subclass)
        super
        definer.added_serializers.each { |serializer| subclass.definer.serializer(serializer) }
      end

      def definer
        @definer ||= create_definer
      end

      def create_definer
        SerializerDefiner.new
      end

      def reset!
        @definer = nil
      end
    end
  end
end
