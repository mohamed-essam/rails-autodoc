# frozen_string_literal: true

require 'autodoc/helpers'
require 'autodoc/documenter/routes'
require 'autodoc/documenter/merger'

require 'active_support/core_ext'

require 'byebug'

module Autodoc
  # Middleware for capturing data
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @status, headers, @body = @app.call(env)

      @path = Documenter::Routes.path_from_env(env)
      @env = env

      document

      [@status, headers, @body]
    end

    def document
      @data = Autodoc.read

      new_data = {
        request: document_request,
        response: document_response
      }

      Autodoc.write(new_data)
    end

    def document_response
      data = @data[:response] || {}

      Helpers.hash_deep(data, @path, Documenter::Routes.method(@env))

      new_data = Documenter::Merger.merge_results(
        current_response(data), Documenter::Merger.doc_body(@body)
      )
      current_response_set(data, new_data)

      data
    end

    def current_response(data)
      data[@path][Documenter::Routes.method(@env)][@status]
    end

    def current_response_set(data, new_data)
      data[@path][Documenter::Routes.method(@env)][@status] = new_data
    end

    def document_request
      data = @data[:request] || {}

      return data unless @status == 200

      request = Rack::Request.new(@env)

      Helpers.hash_deep(data, @path, Documenter::Routes.method(@env))
      params = Helpers.hashify(request.params)

      new_data = Documenter::Merger.merge_results(current_request(data), params)
      current_request_set(data, new_data)

      data
    end

    def current_request(data)
      data[@path][Documenter::Routes.method(@env)]
    end

    def current_request_set(data, new_data)
      data[@path][Documenter::Routes.method(@env)] = new_data
    end
  end
end
