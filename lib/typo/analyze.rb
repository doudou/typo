module Typo
    class Analyze
        State = Struct.new :result, :last_type

        SINGLETON_VALUES = Hash[nil: Constant.new(nil), true: Constant.new(true), false: Constant.new(false)]

        def analyze_method(method)
            source_code = method.source
            ast = Parser::CurrentRuby.parse(source_code)
            if ast.type != :def
                raise ArgumentError, "returned AST is not a method definition"
            end

            state = State.new(MethodAnalysis.new(method), AnyType.new)
            catch :return do
                ast.children[2..-1].each do |element|
                    analyze_expression(element, state)
                end
            end
            state.result.return_type = state.last_type
            state.result
        end

        def analyze_expression(expression, state)
            if expression.kind_of?(AST::Node)
                if expression.type == :return
                    if expression.children.empty?
                        state.last_type = Constant.new(nil)
                    else
                        return_args = expression.children.map do |child|
                            analyze_expression(child, state)
                            state.last_type
                        end
                        if return_args.size == 1
                            state.last_type = return_args[0]
                        else
                            state.last_type = KnownClass.new(Array)
                        end
                    end
                    throw :return
                elsif v = SINGLETON_VALUES[expression.type]
                    state.last_type = v
                elsif literal?(expression)
                    state.last_type = Constant.new(expression.children[0])
                end
            else
                case expression
                when NilClass, FalseClass, TrueClass
                    state.last_type = Constant.new(nil)
                else
                    warn "don't know how to handle literal #{expression}"
                end
            end
        end

        LITERAL_NODES = [:int, :float, :complex, :rational, :str, :string, :sym]

        def literal?(element)
            LITERAL_NODES.include?(element.type)
        end
    end
end

