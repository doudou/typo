module Typo
    class Analyze
        SINGLETON_VALUES = Hash[
            nil: Constant.new(nil),
            true: Constant.new(true),
            false: Constant.new(false)]

        def analyze_method(method)
            source_code = method.source
            ast = Parser::CurrentRuby.parse(source_code)
            if ast.type != :def
                raise ArgumentError, "returned AST is not a method definition"
            end

            state = State.new(method)
            state.result.return_type = catch :return do
                ast.children[2..-1].each do |element|
                    analyze_expression(element, state)
                end
                state.last_type
            end
            state.finalize
            state.result
        end

        def analyze_expression(expression, state)
            if expression.kind_of?(AST::Node)
                if expression.type == :begin
                    expression.children.each do |child|
                        analyze_expression(child, state)
                    end
                elsif expression.type == :lvasgn
                    process_assignment(expression, state, expression_node: expression.children[1])
                elsif expression.type == :masgn
                    process_assignment(expression.children[0], state, expression_node: expression.children[1])
                elsif expression.type == :return
                    if expression.children.empty?
                        throw :return, Constant.new(nil)
                    else
                        return_args = expression.children.map do |child|
                            analyze_expression(child, state)
                            state.last_type
                        end
                        if return_args.size == 1
                            throw :return, return_args[0]
                        else
                            throw :return, KnownClass.new(Array)
                        end
                    end
                elsif v = SINGLETON_VALUES[expression.type]
                    state.last_type = v
                elsif literal?(expression)
                    state.last_type = Constant.new(expression.children[0])
                else
                    warn "don't know how to handle node #{expression.type}"
                    AnyType.new
                end
            else
                case expression
                when NilClass, FalseClass, TrueClass
                    state.last_type = Constant.new(nil)
                else
                    warn "don't know how to handle literal #{expression}"
                    AnyType.new
                end
            end
        end

        def process_assignment(assignment_node, state, expression_node: nil, expression_type: nil)
            if assignment_node.type == :lvasgn
                expression_type ||= analyze_expression(expression_node, state)
                state.local_variable_set(assignment_node, assignment_node.children[0], expression_type)
                expression_type
            elsif assignment_node.type == :mlhs
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
                                process_assignment(lhs, state, expression_type: AnyType.new)
                            elsif i_child = rhs_children[i]
                                if i_child.type == :splat
                                    splat = true
                                    process_assignment(lhs, state, expression_type: AnyType.new)
                                else
                                    process_assignment(lhs, state, expression_node: i_child)
                                end
                            else
                                process_assignment(lhs, state, expression_type: SINGLETON_VALUES[:nil])
                            end
                        end
                    else
                        mlhs.children.each do |lhs|
                            process_assignment(lhs, state, expression_type: AnyType.new)
                        end
                    end
                end
            end
        end

        LITERAL_NODES = [:int, :float, :complex, :rational, :str, :string, :sym]

        def literal?(element)
            LITERAL_NODES.include?(element.type)
        end
    end
end

