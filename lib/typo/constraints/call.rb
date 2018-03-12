module Typo
    module Constraints
        class Call
            attr_reader :name
            attr_reader :return_type

            def initialize(receiver, name, args, kwargs)
                @receiver = receiver
                @name = name
                @arguments = args
                @keyword_arguments = kwargs
                @return_type = Type.Any
            end
        end
    end
end
