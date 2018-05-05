# frozen_string_literal: true

module Autodoc
  module Documenter
    # Helper class for merging results
    module Merger
      class << self
        def merge_results(old_res, new_res)
          return old_res || new_res unless old_res && new_res
          unless old_res.is_a? new_res.class
            raise IncompatibleTypesError, 'Failed to document endpoint, '\
            'incompatible types found and cannot be merged, ' \
            "Type 1: #{old_res.class}, " \
            "Type 2: #{new_res.class}"
          end
          handle_type(old_res, new_res)
        end

        def doc_body(body)
          raw_body = parsed_body(body)
          remove_arrays(raw_body)
        end

        private

        def string_body(body)
          string_body = ''
          body.each { |e| string_body += e }
          string_body
        end

        def parsed_body(body)
          JSON.parse(string_body(body))
        rescue StandardError
          { 'body' => string_body(body) }
        end

        def remove_arrays(body)
          if body.is_a? Array
            reduce_array(body)
          elsif body.is_a? Hash
            reduce_hash(body)
          else
            body
          end
        end

        def reduce_array(body)
          body = [body.reduce(merge_method(body.first))]
          [remove_arrays(body.first)]
        end

        def reduce_hash(body)
          new_body = body.map do |k, v|
            {
              k => remove_arrays(v)
            }
          end
          new_body.reduce(:merge)
        end

        def merge_method(obj)
          return :deep_merge if obj.is_a? Hash
          :+
        end

        def handle_type(old_res, new_res)
          if old_res.is_a? Array
            [merge_results(old_res.first, new_res.first)]
          elsif old_res.is_a? Hash
            handle_hash(old_res, new_res)
          else
            old_res
          end
        end

        def handle_hash(old_res, new_res)
          keys = (old_res.keys + new_res.keys).uniq
          keys.map! do |key|
            {
              key => merge_results(old_res[key], new_res[key])
            }
          end
          keys.reduce(:merge)
        end
      end
    end
  end
end
