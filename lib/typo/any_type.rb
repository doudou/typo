module Typo
    # A type interface that represents an unconstrained type
    class AnyType
        # (see Type#narrow)
        def narrow(type)
            type
        end

        # (see Type#compatible_with_type?)
        def compatible_with_type?(type)
            true
        end

        # (see Type#describes_value?)
        def describes_value?(value)
            true
        end

        # (see Type#describes_class?)
        def describes_class?(klass)
            true
        end
    end
end

