module Typo
    # A known class
    class KnownClass
        # The class object
        attr_reader :klass

        def initialize(klass)
            @klass = klass
        end

        # (see Type#describes_value?)
        def describes_value?(value)
            describes_class?(value.class)
        end

        # (see Type#describes_class?)
        def describes_class?(klass)
            klass <= @klass
        end

        # (see Type#compatible_with_type?)
        def compatible_with_type?(type)
            type.describes_class?(@klass)
        end

        # (see Type#narrow)
        def narrow(type)
            if !compatible_with_type?(type)
                raise NarrowingIncompatibility, "#{@klass} is incompatible with #{type}, cannot narrow"
            end
            self
        end

        def ==(other)
            other.kind_of?(KnownClass) && other.klass == @klass
        end
    end
end

