require_relative 'test_helper'

module Typo
    describe "return type" do
        include Helpers

        describe "last expression" do
            before do
                @analyzer = Analyze.file(File.expand_path("return_type.rb", __dir__))
                @return = @analyzer.class_info(:ReturnType, :LastExpression)
            end

            it "analyzes an empty method" do
                analyzed = @return.method_info(:blank_method)
                assert analyzed.empty?
                assert_constant nil, analyzed.return_type
            end

            it "analyzes a method that returns a nil literal" do
                analyzed = @return.method_info(:nil_literal)
                assert_constant nil, analyzed.return_type
            end

            it "analyzes a method that returns a true literal" do
                analyzed = @return.method_info(:true_literal)
                assert_constant true, analyzed.return_type
            end

            it "analyzes a method that returns a false literal" do
                analyzed = @return.method_info(:false_literal)
                assert_constant false, analyzed.return_type
            end

            it "analyzes a method that returns an integer literal" do
                analyzed = @return.method_info(:integer_literal)
                assert_constant 42, analyzed.return_type
            end

            it "analyzes a method that returns a float literal" do
                analyzed = @return.method_info(:float_literal)
                assert_constant 4.2, analyzed.return_type
            end

            it "analyzes a method that returns a complex literal" do
                analyzed = @return.method_info(:complex_literal)
                assert_constant 1i, analyzed.return_type
            end

            it "analyzes a method that returns a rational literal" do
                analyzed = @return.method_info(:rational_literal)
                assert_constant 3/10r, analyzed.return_type
            end
        end

        describe "return statement" do
            before do
                @analyzer = Analyze.file(File.expand_path("return_type.rb", __dir__))
                @return = @analyzer.class_info(:ReturnType, :ReturnStatement)
            end

            it "analyzes a method that has a return without arguments" do
                analyzed = @return.method_info(:return_without_arguments)
                assert_constant nil, analyzed.return_type
            end

            it "analyzes a method that returns multiple values" do
                analyzed = @return.method_info(:return_multiple_values)
                assert_known_class Array, analyzed.return_type
            end

            it "analyzes a method that returns a nil literal" do
                analyzed = @return.method_info(:nil_literal)
                assert_constant nil, analyzed.return_type
            end

            it "analyzes a method that returns a true literal" do
                analyzed = @return.method_info(:true_literal)
                assert_constant true, analyzed.return_type
            end

            it "analyzes a method that returns a false literal" do
                analyzed = @return.method_info(:false_literal)
                assert_constant false, analyzed.return_type
            end

            it "analyzes a method that returns an integer literal" do
                analyzed = @return.method_info(:integer_literal)
                assert_constant 42, analyzed.return_type
            end

            it "analyzes a method that returns a float literal" do
                analyzed = @return.method_info(:float_literal)
                assert_constant 4.2, analyzed.return_type
            end

            it "analyzes a method that returns a complex literal" do
                analyzed = @return.method_info(:complex_literal)
                assert_constant 1i, analyzed.return_type
            end

            it "analyzes a method that returns a rational literal" do
                analyzed = @return.method_info(:rational_literal)
                assert_constant 3/10r, analyzed.return_type
            end
            it "resolves local variables to their type" do
                analyzed = @return.method_info(:return_local_variable)
                assert_constant 2, analyzed.return_type
            end
        end
    end
end

