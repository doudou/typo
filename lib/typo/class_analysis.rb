module Typo
    class ClassAnalysis
        def initialize(klass)
            @klass = klass
            @instance_methods = Hash.new
            @instance_variables = Hash.new
        end

        def instance_variable_update(name, type)
            if var = @instance_variables[name]
                var.type = var.type.update(type)
            else
                @instance_variables[name] = Variable.new(name, type)
            end
        end

        def instance_variable_get(name)
            @instance_variables.fetch(name).type
        end

        def instance_variable_get_or_create(name)
            (@instance_variables[name] ||= Variable.new(name, Type.Any)).type
        end

        def register_instance_method(instance_method)
            @instance_methods[instance_method.name] = instance_method
        end
    end
end

