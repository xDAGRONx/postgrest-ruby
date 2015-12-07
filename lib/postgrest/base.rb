module PostgREST
  class Base
    def initialize(args = {})
      @info = {}

      (args || {}).each_pair do |k, v|
        @info[k.to_sym] = v
      end
    end

    def to_h
      Hash[@info]
    end

    alias info to_h
  end
end
