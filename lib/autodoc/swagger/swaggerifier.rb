# frozen_string_literal: true

module Autodoc
  module Swagger
    # Helper for converting json to swagger objects
    module Swaggerifier
      SWAGGER_TYPES = {
        Hash => 'object',
        Array => 'array',
        Fixnum => 'number',
        String => 'string',
        TrueClass => 'boolean',
        FalseClass => 'boolean'
      }.freeze

      def swagger_object(json)
        return {} unless json.count.positive?
        {
          'type' => 'object',
          'properties' => json.map do |k, v|
            {
              k => swaggerify_json(v)
            }
          end.reduce(:merge)
        }
      end

      def swagger_array(json)
        {
          'type' => 'array',
          'items' => swaggerify_json(json.first)
        }
      end

      def swagger_string(json)
        {
          'type' => 'string',
          'example' => json.to_s
        }
      end

      def swagger_number(json)
        {
          'type' => 'number',
          'example' => json
        }
      end

      def swagger_boolean(_json)
        {
          'type' => 'boolean'
        }
      end

      def swagger_unknown
        {
          'type' => 'string'
        }
      end

      def swaggerify_json(json)
        type = SWAGGER_TYPES[json.class]
        return send("swagger_#{type}", json) if type
        swagger_unknown
      end

      def swaggerify_params(method_request, path)
        swagger_params(method_request) + swaggerify_path_params(path)
      end

      def swaggerify_responses(method_responses)
        method_responses.map do |resp, _v|
          {
            resp.to_i => {
              'schema' => swaggerify_json(method_responses[resp]),
              'description' => http_code_desc(resp.to_i)
            }
          }
        end.reduce(:merge)
      end

      def http_code_desc(code)
        Rack::Utils::HTTP_STATUS_CODES[code] || 'Unknown'
      end

      def swagger_params(method_request)
        params = swaggerify_json(method_request)
        return [] if params.count.zero?
        [
          {
            'in' => 'body',
            'name' => 'body',
            'schema' => swaggerify_json(method_request)
          }
        ]
      end

      def swaggerify_path_params(path)
        path_params(path).map do |param|
          name = param[1...-1]
          {
            'in' => 'path',
            'name' => name,
            'required' => true,
            'type' => predict_type(name)
          }
        end
      end

      def path_params(path)
        path.split('/').select do |part|
          part =~ /\{[a-z_]+\}/
        end
      end
    end
  end
end
