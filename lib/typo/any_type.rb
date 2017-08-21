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

        # (see Type#compatible_with_value?)
        def compatible_with_value?(value)
            true
        end
    end
end

