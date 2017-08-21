module Typo
    # A constant value pretending to be a type
    class Constant
        # The actual constant value
        attr_reader :value
        
        def initialize(value)
            @value = value
        end

        # (see Type#compatible_with_value?)
        def compatible_with_value?(value)
            @value == value
        end

        # (see Type#compatible_with_type?)
        def compatible_with_type?(type)
            type.compatible_with_value?(@value)
        end

        # (see Type#narrow)
        def narrow(type)
            if !compatible_with_type?(type)
                raise NarrowingIncompatibility, "#{value} is incompatible with #{type}, cannot narrow"
            end
            self
        end

        def ==(other)
            other.kind_of?(Constant) && other.value == @value
        end
    end
end
