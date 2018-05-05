# frozen_string_literal: true

require 'autodoc/version'
require 'autodoc/middleware'
require 'autodoc/config'
require 'autodoc/swagger'
require 'byebug'

# Main module
module Autodoc
  class << self
    attr_accessor :in_memory_data

    def configure
      yield config
    end

    def start
      config.enabled = true
    end

    def stop
      config.enabled = false
    end

    def read_from(&block)
      config.read_from = block
    end

    def write_to(&block)
      config.write_to = block
    end

    def read
      config.read_from.call || {}
    end

    def write(data)
      config.write_to.call(data)
    end

    def config
      @config ||= Config.new
    end

    def read_as(type, opts)
      return nil unless %i[json yaml swagger].include? type
      send("read_#{type}", opts)
    end

    def read_json(_opts)
      read
    end

    def read_yaml(_opts)
      YAML.dump(read)
    end

    def read_swagger(opts); end
  end

  class IncompatibleTypesError < StandardError; end
end
