# frozen_string_literal: true

require 'byebug'

require 'autodoc/swagger/swaggerifier'

module Autodoc
  # Convert to swagger docs style json
  module Swagger
    extend Swaggerifier

    INTEGER_NAMES = %w[id number].freeze

    class << self
      def to_swagger(opts, json_data)
        {
          'swagger' => '2.0',
          'info' => {
            'version' => '1.0',
            'title' => opts.dig(:info, :title),
            'description' => opts.dig(:info, :description)
          },
          'paths' => paths_data(json_data),
          'host' => opts[:host]
        }
      end

      def paths_data(json_data)
        paths = json_data[:response].keys
        paths.map do |path|
          path_requests = json_data[:request][path]
          path_responses = json_data[:response][path]
          methods = [
            path_responses&.keys, path_requests&.keys
          ].reject(&:nil?).reduce(:+)

          methods_data(path, methods, json_data)
        end.reduce(:merge)
      end

      def methods_data(path, methods, json_data)
        path_requests = json_data[:request][path]
        path_responses = json_data[:response][path]
        value = methods.map do |method|
          method_request = path_requests[method]
          method_responses = path_responses[method]
          method_data(path, method, method_request, method_responses)
        end.reduce(:merge)
        {
          path => value
        }
      end

      def method_data(path, method, method_request, method_responses)
        {
          method.downcase => {
            'tags' => [tag(path)],
            'consumes' => ['application/json'],
            'produces' => ['application/json'],
            'parameters' => swaggerify_params(method_request, path),
            'responses' => swaggerify_responses(method_responses)
          }
        }
      end

      def predict_type(name)
        if INTEGER_NAMES.select { |e| name.include? e }.count.positive?
          'integer'
        else
          'string'
        end
      end

      def tag(path)
        return unless Autodoc.config.tag_by
        parts = path.split('/')
        return nil if parts.count <= Autodoc.config.tag_by
        parts[Autodoc.config.tag_by]
      end
    end
  end
end
