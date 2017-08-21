module Typo
    class MethodAnalysis
        # The method object
        attr_reader :method

        # The return type
        attr_accessor :return_type

        # The argument types
        attr_reader :argument_types

        # The local variable types
        attr_reader :argument_types

        def initialize(method)
            @method = method
            @return_type = AnyType.new
            @argument_types = Hash.new
            @local_variable_types = Hash.new
        end

        def empty?
            @argument_types.empty? && @local_variable_types.empty?
        end
    end
end

