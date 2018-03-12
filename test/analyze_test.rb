require 'test_helper'

module Typo
    describe Analyze do
        before do
            @analyzer = Analyze.new
        end

        def assert_is_any(type)
            assert type.any?
        end

        def assert_known_class(klass, type)
            assert type.has_known_class?(klass)
        end

        def assert_constant(value, type)
            assert type.has_known_value?(value)
        end

        def assert_would_respond_to(m, type)
            assert type.would_respond_to?(m)
        end

        describe "return type" do
            describe "last expression" do
                before do
                    @context = ReturnTypeTest::LastExpression
                end

                it "analyzes an empty method" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:blank_method))
                    assert analyzed.empty?
                    assert_constant nil, analyzed.return_type
                end

                it "analyzes a method that returns a nil literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:nil_literal))
                    assert_constant nil, analyzed.return_type
                end

                it "analyzes a method that returns a true literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:true_literal))
                    assert_constant true, analyzed.return_type
                end

                it "analyzes a method that returns a false literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:false_literal))
                    assert_constant false, analyzed.return_type
                end

                it "analyzes a method that returns an integer literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:integer_literal))
                    assert_constant 42, analyzed.return_type
                end

                it "analyzes a method that returns a float literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:float_literal))
                    assert_constant 4.2, analyzed.return_type
                end

                it "analyzes a method that returns a complex literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:complex_literal))
                    assert_constant 1i, analyzed.return_type
                end

                it "analyzes a method that returns a rational literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:rational_literal))
                    assert_constant 3/10r, analyzed.return_type
                end
            end

            describe "return statement" do
                before do
                    @context = ReturnTypeTest::ReturnStatement
                end

                it "analyzes a method that has a return without arguments" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:return_without_arguments))
                    assert_constant nil, analyzed.return_type
                end

                it "analyzes a method that returns multiple values" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:return_multiple_values))
                    assert_known_class Array, analyzed.return_type
                end

                it "analyzes a method that returns a nil literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:nil_literal))
                    assert_constant nil, analyzed.return_type
                end

                it "analyzes a method that returns a true literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:true_literal))
                    assert_constant true, analyzed.return_type
                end

                it "analyzes a method that returns a false literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:false_literal))
                    assert_constant false, analyzed.return_type
                end

                it "analyzes a method that returns an integer literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:integer_literal))
                    assert_constant 42, analyzed.return_type
                end

                it "analyzes a method that returns a float literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:float_literal))
                    assert_constant 4.2, analyzed.return_type
                end

                it "analyzes a method that returns a complex literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:complex_literal))
                    assert_constant 1i, analyzed.return_type
                end

                it "analyzes a method that returns a rational literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:rational_literal))
                    assert_constant 3/10r, analyzed.return_type
                end
                it "resolves local variables to their type" do
                    analyzed = @analyzer.analyze_method(
                        @context.instance_method(:return_local_variable))
                    assert_constant 2, analyzed.return_type
                end
            end
        end

        describe "assignment" do
            before do
                @context = LocalVariableAssignationTest
            end

            it "assigns local variables type to the value" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:simple))
                assert_constant 2, analyzed.local_variable_get(:a, 0)
            end

            it "handles sequential assignments" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:chained))
                assert_constant 2, analyzed.local_variable_get(:a, 0)
                assert_constant 2, analyzed.local_variable_get(:b, 0)
            end

            it "handles local variables being re-assigned assignments" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:re_assigned))
                assert_constant 2, analyzed.local_variable_get(:a, 0)
                assert_constant false, analyzed.local_variable_get(:a, 1)
            end

            it "handles straightforward parallel assignment" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:parallel))
                assert_constant 2, analyzed.local_variable_get(:a, 0)
                assert_constant 3, analyzed.local_variable_get(:b, 0)
            end

            it "handles parallel assignment with too little values" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:parallel_too_short))
                assert_constant 2, analyzed.local_variable_get(:a, 0)
                assert_constant nil, analyzed.local_variable_get(:b, 0)
            end

            it "handles parallel assignment with a splat" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:parallel_splat))
                assert_constant 2, analyzed.local_variable_get(:a, 0)
                assert_is_any analyzed.local_variable_get(:b, 0)
                assert_is_any analyzed.local_variable_get(:c, 0)
            end
        end
    
        describe "simple expressions" do
            before do
                @context = SimpleExpressions
            end

            it "recognizes inclusive ranges" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:range_inclusive))
                assert_known_class Range, analyzed.local_variable_get(:a, 0)
            end
            it "recognizes exclusive ranges" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:range_exclusive))
                assert_known_class Range, analyzed.local_variable_get(:a, 0)
            end

            it "recognizes captures" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:regexp_capture))
                assert_known_class String, analyzed.local_variable_get(:a, 0)
            end
            it "recognizes back-references" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:regexp_backref))
                assert_known_class String, analyzed.local_variable_get(:a, 0)
            end
            it "recognizes hash literals" do
                analyzed = @analyzer.analyze_method(
                    @context.instance_method(:hash))
                assert_known_class Hash, analyzed.local_variable_get(:a, 0)
            end
        end

        describe "instance variables" do
            before do
                @context = IVar
            end

            it "updates the ivar type on write" do
                @analyzer.analyze_method(
                    @context.instance_method(:assign))
                ivar = @analyzer.class_info(@context).
                    instance_variable_get(:@a)
                assert_constant 42, ivar
            end

            it "updates the ivar type on call" do
                @analyzer.analyze_method(
                    @context.instance_method(:call))
                ivar = @analyzer.class_info(@context).
                    instance_variable_get(:@a)
                assert_would_respond_to :test, ivar
            end

            it "accumulates information on a single ivar" do
                @analyzer.analyze_method(
                    @context.instance_method(:first))
                @analyzer.analyze_method(
                    @context.instance_method(:second))
                ivar = @analyzer.class_info(@context).
                    instance_variable_get(:@a)
                assert_would_respond_to :first, ivar
                assert_would_respond_to :second, ivar
            end

            it "recognizes the link between attr_reader and the ivar" do
            end

            it "recognizes the link between attr_writer and the ivar" do
            end

            it "recognizes the link between attr_accessor and the ivar" do
            end
        end

        describe "instance variables" do
        end

        describe "method calls" do
            it "adds a plain method call as a Call constraint on the receiver" do
            end
            it "adds a plain method call as a Argument constraint on its arguments" do
            end
            it "plain method call" do
            end
        end
    end

    class ReturnTypeTest
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

    class LocalVariableAssignationTest
        def simple
            a = 2
        end
        def chained
            a = b = 2
        end
        def re_assigned
            a = 2
            a = false
        end
        def parallel
            a, b = 2, 3
        end
        def parallel_too_short
            a, b = 2
        end
        def parallel_splat
            a, b, c = 2, *d
        end
    end

    class SimpleExpressions
        def regexp_capture
            a = $1
        end
        def regexp_backref
            a = $`
        end

        def range_inclusive
            a = (1..2)
        end
        def range_exclusive
            a = (1...2)
        end
        def hash
            a = {}
        end
    end

    class IVar
        def assign
            @a = 42
        end

        def call
            @a.test
        end

        def first
            @a.first
        end

        def second
            @a.second
        end
    end

    class Attr
        attr_writer :writer
        attr_reader :reader
        attr_accessor :accessor

        def writer_access
            self.writer = 10
        end

        def reader_access
            a = reader
            a.some_call
        end

        def accessor_read
            a = accessor
            a.some_call
        end

        def accessor_write
            self.accessor = 10
        end
    end

    class CallExpressions
        def single_call(a)
            a.do_something
        end
        def multiple_call(a)
            a.do_something
            a.do_something_else
        end
        def conditional_call_with_else(a)
            a.begin_call
            if some_condition
                a.left
            else
                a.right
            end
            b.end_call
        end
        def conditional_call_without_else(a)
            a.begin_call
            if some_condition
                a.first
            elsif other_condition
                a.second
            end
            a.end_call
        end
    end
end

