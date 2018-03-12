module Typo
    class MethodAnalysis
        # The method name
        attr_reader :name

        # The return type
        attr_accessor :return_type

        # The argument types
        attr_reader :argument_types

        LocalVariable = Struct.new :node, :name, :version, :type

        # The local variable types
        attr_reader :local_variables

        def initialize(klass, name)
            @klass  = klass
            @name   = name.to_s
            @return_type = Type.Any
            @argument_types = Hash.new
            @local_variables = Hash.new
        end

        def empty?
            @argument_types.empty? && @local_variables.empty?
        end

        def instance_variable_get_or_create(name)
            @klass.instance_variable_get_or_create(name)
        end

        def instance_variable_get(name)
            @klass.instance_variable_get(name)
        end

        def instance_variable_update(name, type)
            @klass.instance_variable_update(name, type)
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

        def return_type_update(type)
            @return_type.update(type)
        end
    end
end

