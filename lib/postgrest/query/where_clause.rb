module PostgREST
  class Query
    class WhereClause
      attr_reader :query
      alias encode query

      def initialize(query)
        @query = process_query(query)
      end

      private

      def process_query(params)
        params.each_with_object(hash_of_arrays) do |(key, value), result|
          case value
          when Array
            result[key] << "in.#{value.join(',')}"
          when Range
            result[key] << "gte.#{value.first}"
            result[key] << "lte.#{value.last}"
          when Hash
            value.each_pair { |k, v| result[key] << "#{k}.#{v}" }
          when TrueClass, FalseClass
            result[key] << "is.#{value}"
          when NilClass
            result[key] << 'is.null'
          else
            result[key] << "eq.#{value}"
          end
        end
      end

      def hash_of_arrays
        Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end
