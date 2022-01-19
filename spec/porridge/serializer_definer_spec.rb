# frozen_string_literal: true

require 'spec_helper'

describe Porridge::SerializerDefiner do
  let(:instance) { described_class.new }

  it_behaves_like 'SerializerDefiner'
end
