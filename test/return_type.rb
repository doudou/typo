class ReturnType
    class LastExpression
        def blank_method; end
        def nil_literal; nil end
        def true_literal; true end
        def false_literal; false end
        def integer_literal; 42 end
        def float_literal; 4.2 end
        def complex_literal; 1i end
        def rational_literal; 0.3r end
    end

    class ReturnStatement
        def return_without_arguments; return; end
        def return_local_variable
            a = 2
            return a
        end
        def return_multiple_values; return 1, 2, false end
        def nil_literal; return nil; end
        def true_literal; return true end
        def false_literal; return false end
        def integer_literal; return 42 end
        def float_literal; return 4.2 end
        def complex_literal; return 1i end
        def rational_literal; return 0.3r end
    end
end

