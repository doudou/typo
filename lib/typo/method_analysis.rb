module Typo
    class MethodAnalysis
        # The method object
        attr_reader :method

        # The return type
        attr_accessor :return_type

        # The argument types
        attr_reader :argument_types

        LocalVariable = Struct.new :node, :name, :version, :type

        # The local variable types
        attr_reader :local_variables

        def initialize(method)
            @method = method
            @return_type = AnyType.new
            @argument_types = Hash.new
            @local_variables = Hash.new
        end

        def empty?
            @argument_types.empty? && @local_variables.empty?
        end

        def local_variable_set(node, name, type)
            if versions = local_variables[name]
                versions << LocalVariable.new(node, name, versions.size, type)
            else
                local_variables[name] = [LocalVariable.new(node, name, 0, type)]
            end
        end

        def local_variable_get(name, version)
            @local_variables[name][version].type
        end
    end
end

