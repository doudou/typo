module Typo
    class Type
        def self.KnownClass(klass)
            result = new
            result.add_known_class(klass)
            result
        end

        def self.Constant(value)
            result = new
            result.add_known_value(value)
            result
        end

        def self.Any
            new
        end

        def initialize
            @constraints = Array.new
            @known_values = Array.new
            @known_class = Array.new
        end

        def initialize_copy(old)
            super
            @constraints  = @constraints.dup
            @known_values = @known_values.dup
            @known_class  = @known_class.dup
        end

        def any?
            @constraints.empty? &&
                @known_values.empty? &&
                @known_class.empty?
        end

        def add_known_class(klass)
            @known_class << klass
        end

        def has_known_class?(klass)
            @known_class.include?(klass)
        end

        def add_known_value(value)
            @known_values << value
        end

        def has_known_value?(value)
            @known_values.include?(value)
        end

        def update(type)
            @constraints.concat(type.instance_variable_get(:@constraints))
        end

        def add_call(m, *args, **kwargs)
            constraint = Constraints::Call.new(self, m, args, kwargs)
            add_constraint constraint
            constraint
        end

        def would_respond_to?(m)
            @constraints.any? do |c|
                c.kind_of?(Constraints::Call) && (c.name == m)
            end
        end

        def add_constraint(constraint)
            @constraints << constraint
        end
    end
end

