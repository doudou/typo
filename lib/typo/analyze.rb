module Typo
    class Analyze
        State = Struct.new :result, :last_type

        def analyze_method(method)
            source_code = method.source
            ast = Parser::CurrentRuby.parse(source_code)
            if ast.type != :def
                raise ArgumentError, "returned AST is not a method definition"
            end

            result = MethodAnalysis.new(method)
            last_type = AnyType.new
            state = State.new(result, last_type)

            ast.children[2..-1].each do |element|
                if element.kind_of?(AST::Node)
                    if literal?(element)
                        last_type = last_type.narrow(Constant.new(element.children[0]))
                    end
                else
                    case element
                    when NilClass, FalseClass, TrueClass
                        last_type = last_type.narrow(Constant.new(nil))
                    else
                        warn "don't know how to handle literal #{element}"
                    end
                end
            end
            result.return_type = last_type
            result
        end

        LITERAL_NODES = [:int, :float, :complex, :rational, :str, :string, :sym]

        def literal?(element)
            LITERAL_NODES.include?(element.type)
        end
    end
end

