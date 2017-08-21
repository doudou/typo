require 'test_helper'

module Typo
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

    describe Analyze do
        before do
            @analyzer = Analyze.new
        end

        describe "return type" do
            describe "last expression" do
                before do
                    @context = ReturnTypeTest::LastExpression
                end

                it "analyzes an empty method" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:blank_method))
                    assert analyzed.empty?
                    assert_kind_of Constant, analyzed.return_type
                    assert_same nil, analyzed.return_type.value
                end

                it "analyzes a method that returns a nil literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:nil_literal))
                    assert_equal Constant.new(nil), analyzed.return_type
                end

                it "analyzes a method that returns a true literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:true_literal))
                    assert_equal Constant.new(true), analyzed.return_type
                end

                it "analyzes a method that returns a false literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:false_literal))
                    assert_equal Constant.new(false), analyzed.return_type
                end

                it "analyzes a method that returns an integer literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:integer_literal))
                    assert_equal Constant.new(42), analyzed.return_type
                end

                it "analyzes a method that returns a float literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:float_literal))
                    assert_equal Constant.new(4.2), analyzed.return_type
                end

                it "analyzes a method that returns a complex literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:complex_literal))
                    assert_equal Constant.new(1i), analyzed.return_type
                end

                it "analyzes a method that returns a rational literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:rational_literal))
                    assert_equal Constant.new(3/10r), analyzed.return_type
                end
            end

            describe "return statement" do
                before do
                    @context = ReturnTypeTest::ReturnStatement
                end

                it "analyzes a method that has a return without arguments" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:return_without_arguments))
                    assert_equal Constant.new(nil), analyzed.return_type
                end

                it "analyzes a method that returns multiple values" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:return_multiple_values))
                    assert_equal KnownClass.new(Array), analyzed.return_type
                end

                it "analyzes a method that returns a nil literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:nil_literal))
                    assert_equal Constant.new(nil), analyzed.return_type
                end

                it "analyzes a method that returns a true literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:true_literal))
                    assert_equal Constant.new(true), analyzed.return_type
                end

                it "analyzes a method that returns a false literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:false_literal))
                    assert_equal Constant.new(false), analyzed.return_type
                end

                it "analyzes a method that returns an integer literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:integer_literal))
                    assert_equal Constant.new(42), analyzed.return_type
                end

                it "analyzes a method that returns a float literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:float_literal))
                    assert_equal Constant.new(4.2), analyzed.return_type
                end

                it "analyzes a method that returns a complex literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:complex_literal))
                    assert_equal Constant.new(1i), analyzed.return_type
                end

                it "analyzes a method that returns a rational literal" do
                    analyzed = @analyzer.analyze_method(@context.instance_method(:rational_literal))
                    assert_equal Constant.new(3/10r), analyzed.return_type
                end
            end
        end
    end
end

