require_relative 'test_helper'

module Typo
    describe "assignment" do
        include Helpers

        before do
            @analyzer = Analyze.file(
                File.expand_path("local_variable_assignation.rb", __dir__))
            @lvar = @analyzer.class_info(:LocalVariableAssignation)
        end

        it "assigns local variables type to the value" do
            analyzed = @lvar.method_info(:simple)
            assert_constant 2, analyzed.local_variable_get(:a, 0)
        end

        it "handles sequential assignments" do
            analyzed = @lvar.method_info(:chained)
            assert_constant 2, analyzed.local_variable_get(:a, 0)
            assert_constant 2, analyzed.local_variable_get(:b, 0)
        end

        it "handles local variables being re-assigned assignments" do
            analyzed = @lvar.method_info(:re_assigned)
            assert_constant 2, analyzed.local_variable_get(:a, 0)
            assert_constant false, analyzed.local_variable_get(:a, 1)
        end

        it "handles straightforward parallel assignment" do
            analyzed = @lvar.method_info(:parallel)
            assert_constant 2, analyzed.local_variable_get(:a, 0)
            assert_constant 3, analyzed.local_variable_get(:b, 0)
        end

        it "handles parallel assignment with too little values" do
            analyzed = @lvar.method_info(:parallel_too_short)
            assert_constant 2, analyzed.local_variable_get(:a, 0)
            assert_constant nil, analyzed.local_variable_get(:b, 0)
        end

        it "handles parallel assignment with a splat" do
            analyzed = @lvar.method_info(:parallel_splat)
            assert_constant 2, analyzed.local_variable_get(:a, 0)
            assert_is_any analyzed.local_variable_get(:b, 0)
            assert_is_any analyzed.local_variable_get(:c, 0)
        end
    end
end

