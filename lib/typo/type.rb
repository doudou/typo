module Typo
    class Type
        # Tests whether this type can be used to describe the given Ruby value
        def describes_value?(value)
            raise NotImplementedError
        end

        # Tests whether this type can be used to describe the given Ruby class
        def describes_class?(klass)
            raise NotImplementedError
        end

        # Tests whether self and the argument are compatible
        #
        # Two types are "incompatible" if it is an impossibility that they
        # describe the same underlying type
        def compatible_with_type?(type)
            raise NotImplementedError
        end
    end
end

