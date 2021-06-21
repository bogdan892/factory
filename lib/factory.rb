# frozen_string_literal: true

class Factory
  class << self
    def new(*fields, &block)
      const_set(fields.shift, create_class(*fields, &block)) if fields[0].is_a?(String)
      create_class(*fields, &block)
    end

    def create_class(*fields, &block)
      Class.new do
        attr_reader(*fields)

        define_method :initialize do |*arg|
          raise ArgumentError if fields.count != arg.count

          fields.each_index { |index| instance_variable_set("@#{fields[index]}", arg[index]) }
        end

        def ==(other)
          map_variables == other.map_variables
        end

        def [](val)
          val = val.to_s if val.is_a?(Symbol)
          val.is_a?(String) ? instance_variable_get("@#{val}") : map_variables[val]
        end

        def []=(name, value)
          instance_variable_set("@#{name}", value)
        end

        def map_variables
          instance_variables.map { |variable| instance_variable_get(variable) }
        end

        def each(&block)
          map_variables.each(&block)
        end

        def each_pair(&block)
          instance_variables.map do |variable|
            [variable.to_s.delete('@'), instance_variable_get(variable)]
          end.to_h.each(&block)
        end

        def to_a
          map_variables
        end

        def select(&block)
          map_variables.select(&block)
        end

        def length
          map_variables.length
        end

        def values_at(*values)
          values.map { |key| map_variables.at(key) }
          # map_variables.each_with_index{ |key,value| }
        end

        def dig(*values)
          a =  self
          values.each do |key|
            return nil if a[key].nil?

            a = a[key]
          end
          a
        end

        def members
          instance_variables.map { |variables| variables.to_s.delete('@').to_sym }
        end
        alias_method :size, :length
        class_eval(&block) if block_given?
      end
    end
  end
end
