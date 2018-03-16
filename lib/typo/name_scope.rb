module Typo
    class NameScope
        Constant = Struct.new :name, :name_parts, :type

        def self.Root
            object_class = Type.Any
            module_class = Type.Any
            class_class  = Type.Any

            toplevel = Type.KnownClass(object_class)
            root = new(toplevel, [])
            root.register_scope('<root>', root)
            root.register_constant('Class', class_class)
            root.register_constant('Module', module_class)
            root
        end

        attr_reader :name
        attr_reader :name_parts
        attr_reader :type

        def initialize(type, name_parts, root: self)
            @root = root
            @type = type
            @name_parts = name_parts
            @name = name_parts.join("::")
            @constants = Hash.new
            @methods = Hash.new
            @instance_variables = Hash.new
        end

        def to_s
            "#<NameScope name=#{name}>"
        end

        def resolve_constant(*name)
            return self if name.empty?
            fetch_constant(name.first).resolve_constant(*name[1..-1])
        end

        def find_constant(name)
            @constants[name]
        end

        def fetch_constant(name)
            @constants.fetch(name)
        end

        def register_constant(name, type)
            @constants[name] = Constant.new("#{self.name}::#{name}", @name_parts + [name], type)
        end

        def register_scope(name, scope)
            @constants[name] = scope
        end

        def register_method(name, method)
            @methods[name] = method
        end

        def constant_names
            @constants.keys
        end

        def root?
            @root == self
        end

        def class_type
            @root.find_constant("Class")
        end

        def module_type
            @root.find_constant("Module")
        end

        def class?
            @type.has_known_class?(class_type.type)
        end

        def module?
            @type.has_known_class?(module_type.type)
        end

        def method_info(name)
            @methods.fetch(name)
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
    end
end

