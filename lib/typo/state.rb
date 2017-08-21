module Typo
    class State
        attr_reader :result

        attr_accessor :last_type

        LocalVariable = Struct.new :node, :type

        def initialize(method)
            @result = MethodAnalysis.new(method)
            @last_type = AnyType.new
            @local_variables = Hash.new
        end

        def local_variable_set(node, name, type)
            current = @local_variables[name]
            if current
                result.local_variable_set(current.node, name, current.type)
            end
            @local_variables[name] = LocalVariable.new(node, type)
        end

        def local_variable_get(name)
            @local_variables.fetch(name).type
        end

        def local_variable_update(name, type)
            @local_variables[name].type = type
        end

        def finalize
            @local_variables.each do |name, lv|
                result.local_variable_set(lv.node, name, lv.type)
            end
        end
    end
end

