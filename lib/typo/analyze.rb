module Typo
    class Analyze
        class ParsingError < RuntimeError
        end

        class UnknownConstantName < ParsingError
        end

        def self.file(path)
            file_ast = Parser::CurrentRuby.parse(File.read(path))
            analyzer = new
            analyzer.analyze_toplevel(file_ast)
            analyzer
        end

        KNOWN_TYPES = Hash[
            nil:        Type.Constant(nil),
            true:       Type.Constant(true),
            false:      Type.Constant(false),
            irange:     Type.KnownClass(Range),
            erange:     Type.KnownClass(Range),
            nth_ref:    Type.KnownClass(String),
            back_ref:   Type.KnownClass(String),
            hash:       Type.KnownClass(Hash)]

        attr_reader :root

        def initialize
            @root = NameScope.Root
            @context = [@root]
        end

        def current_context
            @context.last
        end

        def flatten_const_node(node)
            if node
                if node.type == :cbase
                    ['<root>']
                else
                    flatten_const_node(node.children[0]) + [node.children[1]]
                end
            else
                []
            end
        end

        def find_constant(root, *parts)
            anchor = @context.reverse_each.find do |c|
                c.find_constant(root)
            end
            parts.inject(anchor) do |c, n|
                return unless c
                c.find_constant(n)
            end
        end

        def resolve_constant(root, *parts)
            anchor = @context.reverse_each.find do |c|
                c.find_constant(root)
            end
            if anchor
                anchor.resolve_constant(root, *parts)
            else
                raise UnknownConstantName, "cannot find #{root}::#{parts.join("::")}"
            end
        end

        def resolve_definition_constant(*parts)
            reference_context =
                if parts.size > 1
                    resolve_constant(*parts[0..-2])
                else
                    current_context
                end

            if existing = reference_context.find_constant(parts.last)
                existing
            else
                [nil, reference_context, parts.last]
            end
        end

        def analyze_class_or_module(node, expected_type, body_index)
            existing, reference_context, name = resolve_definition_constant(
                *flatten_const_node(node.children[0]))

            if existing
                unless existing.type.has_known_class?(expected_type.type)
                    raise ArgumentError, "expected #{node} in #{current_context.name} to be a #{expected_type.name}, but it is not"
                end
                @context.push(existing)
            else
                new_context = NameScope.new(
                    Type.KnownClass(expected_type.type),
                    [*reference_context.name_parts, name],
                    root: @root)
                reference_context.register_scope(name, new_context)
                @context.push(new_context)
            end

            if body = node.children[body_index]
                analyze_toplevel(body)
            end
            @context.last

        ensure
            @context.pop
        end

        def class_info(*path)
            scope = @root.resolve_constant(*path)
            if scope.class?
                scope
            else
                raise "expected #{scope.name} to be a class, but it is not"
            end
        end

        def analyze_toplevel(ast)
            if ast.type == :begin
                ast.children.each do |node|
                    analyze_toplevel(node)
                end
            elsif ast.type == :module
                analyze_class_or_module(ast, @root.module_type, 1)
            elsif ast.type == :class
                analyze_class_or_module(ast, @root.class_type, 2)
            elsif ast.type == :send
                analyze_class_metacall(ast)
            elsif ast.type == :def
                analyze_method(ast.children[0], ast.children[1])
            else
                puts "ignored #{ast} in analyze_toplevel"
            end
        end

        # Analyzes a method and returns the corresponding type analysis
        def analyze_method(ast)
            state = State.new(current_context)
            state.result.return_type = catch :return do
                ast.children[2..-1].each do |element|
                    analyze_expression(element, state)
                end
                state.last_type
            end
            state.finalize
            state.result
        end

        IVAR_ACCESS_METACALLS = Hash[
            attr_writer: [false, true].freeze,
            attr_reader: [true, false].freeze,
            attr_accessor: [true, true].freeze].freeze

        def analyze_class_metacall(ast)
            if ast.children[0] == nil && info = IVAR_ACCESS_METACALLS[ast.children[1]]
                name = ast.children[2].children[0]
                ivar_name = :"@#{name}"
                if info[1]
                    m = MethodAnalysis.new(current_context)
                    m.argument_types[0] = m.instance_variable_get_or_create(ivar_name)
                    m.return_type =
                        m.instance_variable_get_or_create(ivar_name)
                    current_context.register_method(:"#{name}=", m)
                end
                if info[0]
                    m = MethodAnalysis.new(current_context)
                    m.return_type =
                        m.instance_variable_get_or_create(ivar_name)
                    current_context.register_method(name, m)
                end
            else
                puts "unrecognized metacall #{ast}"
            end
        end

        def analyze_expression(expression, state)
            if expression.kind_of?(AST::Node)
                if expression.type == :begin
                    expression.children.each do |child|
                        analyze_expression(child, state)
                    end
                    state.last_type
                elsif expression.type == :ivasgn
                    process_assignment(expression, state, expression_node: expression.children[1])
                elsif expression.type == :lvar
                    state.local_variable_get(expression.children[0])
                elsif expression.type == :lvasgn
                    process_assignment(expression, state, expression_node: expression.children[1])
                elsif expression.type == :masgn
                    process_assignment(expression.children[0], state, expression_node: expression.children[1])
                elsif expression.type == :return
                    if expression.children.empty?
                        throw :return, Type.Constant(nil)
                    else
                        return_args = expression.children.map do |child|
                            analyze_expression(child, state)
                            state.last_type
                        end
                        if return_args.size == 1
                            throw :return, return_args[0]
                        else
                            throw :return, Type.KnownClass(Array)
                        end
                    end
                elsif expression.type == :send
                    target = process_receiver(expression.children[0], state)
                    target.add_call(expression.children[1]).return_type

                elsif v = KNOWN_TYPES[expression.type]
                    state.last_type = v
                elsif literal?(expression)
                    state.last_type = Type.Constant(expression.children[0])
                else
                    warn "don't know how to handle node #{expression.type}"
                    state.last_type = Type.Any
                end
            else
                case expression
                when NilClass, FalseClass, TrueClass
                    state.last_type = Type.Constant(nil)
                else
                    warn "don't know how to handle literal #{expression}"
                    state.last_type = Type.Any
                end
            end
        end

        def process_receiver(node, state)
            if node.type == :ivar
                return state.instance_variable_get(node.children[0])
            end
        end

        def process_assignment(assignment_node, state, expression_node: nil, expression_type: nil)
            if assignment_node.type == :lvasgn
                expression_type ||= analyze_expression(expression_node, state)
                state.local_variable_set(assignment_node, assignment_node.children[0], expression_type)
                return expression_type
            elsif assignment_node.type == :ivasgn
                expression_type ||= analyze_expression(expression_node, state)
                state.instance_variable_update(assignment_node.children[0], expression_type)
                return expression_type
            end

            if assignment_node.type == :mlhs
                mlhs = assignment_node
                if expression_type
                    mlhs.children.each do |lhs|
                        process_assignment(lhs, state, expression_type: expression_type)
                    end
                else
                    # Try to extract as much info as we can from the expression
                    rhs  = expression_node
                    if rhs.type == :array
                        rhs_children = rhs.children
                    elsif literal?(rhs)
                        rhs_children = [rhs]
                    end

                    if rhs_children
                        splat = false
                        mlhs.children.each_with_index do |lhs, i|
                            if splat
                                process_assignment(lhs, state, expression_type: Type.Any)
                            elsif i_child = rhs_children[i]
                                if i_child.type == :splat
                                    splat = true
                                    process_assignment(lhs, state, expression_type: Type.Any)
                                else
                                    process_assignment(lhs, state, expression_node: i_child)
                                end
                            else
                                process_assignment(lhs, state, expression_type: KNOWN_TYPES[:nil])
                            end
                        end
                    else
                        mlhs.children.each do |lhs|
                            process_assignment(lhs, state, expression_type: Type.Any)
                        end
                    end
                end
                state.last_type = Type.KnownClass(Array)
            else
                warn "don't know how to handle assignment #{assignment_node.type}"
                Type.Any
            end
        end

        LITERAL_NODES = [:int, :float, :complex, :rational, :str, :string, :sym]

        def literal?(element)
            LITERAL_NODES.include?(element.type)
        end
    end
end

