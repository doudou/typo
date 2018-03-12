module Typo
    class Variable
        attr_reader :name
        attr_reader :type

        def initialize(name, type = Type.Any)
            @name = name
            @type = type
        end

        def describes_value?(value)
            @type.describes_value?(value)
        end

        def describes_class?(klass)
            @type.describes_class?(klass)
        end

        def compatible_with_type?(type)
            @type.compatible_with_type?(type)
        end

        def add_call(m, *args)
            @type.add_call(m, *args)
        end
    end
end

