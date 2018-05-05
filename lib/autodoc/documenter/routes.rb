# frozen_string_literal: true

module Autodoc
  module Documenter
    # Routes helper for middleware
    module Routes
      class << self
        def path_from_env(env)
          route = current_route(env).first
          path = path_from_parts(parts(route))
          append_format(path, env)
        end

        def method(env)
          env['REQUEST_METHOD']
        end

        private

        def path_from_parts(parts)
          parts.map do |part|
            next part if part.is_a? String
            if part.is_a? ActionDispatch::Journey::Format::Parameter
              next "{#{part.name}}"
            end
          end.join('')
        end

        def parts(route)
          route
            .instance_variable_get(:@path_formatter)
            .instance_variable_get(:@parts)
        end

        def current_route(env)
          req = Rack::Request.new env

          all_routes(env).select { |route| route_matching?(route, req, env) }
        end

        def route_matching?(route, req, env)
          route.matches?(req) && (route_path_regex(route) =~ env['REQUEST_URI'])
        end

        def route_path_regex(route)
          route.instance_variable_get(:@path).instance_variable_get(:@re)
        end

        def all_routes(env)
          env['action_dispatch.routes'].router.routes.routes
        end

        def append_format(path, env)
          if env['REQUEST_URI'].end_with? '.csv'
            "#{path}.csv"
          else
            path
          end
        end
      end
    end
  end
end
