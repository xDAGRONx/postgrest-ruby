module PostgREST
  class Query
    class OrderClause
      attr_reader :columns

      def initialize(*columns)
        @columns = columns.flatten
      end

      def encode
        query.join(',')
      end

      def join(other)
        self.class.new(columns + other.columns)
      end

      private

      def query
        preprocess_order_args.map { |c| c.join('.') }
      end

      def preprocess_order_args
        columns.each_with_object([]) do |column, result|
          case column
          when Hash
            result.concat(column.map do |k, v|
              [k].concat([*v].map { |m| m.to_s.downcase }.sort)
            end)
          else
            result << [column]
          end
        end
      end
    end
  end
end
