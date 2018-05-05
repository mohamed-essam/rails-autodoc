# frozen_string_literal: true

module Autodoc
  # Configuration class for Autodoc, yielded by main module
  class Config
    attr_accessor :enabled
    attr_accessor :read_from, :write_to
    attr_accessor :in_memory_data
    attr_accessor :tag_by

    def initialize
      @in_memory_data = {}

      @read_from = lambda do
        @in_memory_data
      end

      @write_to = lambda do |data|
        @in_memory_data = data
      end

      @enabled = false
      @tag_by = nil
    end
  end
end
