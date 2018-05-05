# frozen_string_literal: true

module Autodoc
  # Helper methods
  module Helpers
    class << self
      def hash_deep(hash, *keys)
        return if keys.length.zero?
        key = keys.shift
        hash[key] ||= {}
        hash_deep(hash[key], *keys)
      end

      def hashify(obj)
        if hash?(obj)
          hashify_hash(obj)
        elsif obj.is_a?(Array)
          obj.map { |e| hashify(e) }
        else
          obj
        end
      end

      private

      def hash?(obj)
        obj.is_a?(Hash) || obj.is_a?(ActiveSupport::HashWithIndifferentAccess)
      end

      def hashify_hash(obj)
        obj.map do |k, v|
          {
            k.to_s => hashify(v)
          }
        end.reduce(:merge)
      end
    end
  end
end
