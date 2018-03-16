require_relative 'test_helper'

module Typo
    describe "simple expressions" do
        include Helpers

        before do
            @analyzer = Analyze.file(File.expand_path("simple_expressions.rb", __dir__))
            @simple = @analyzer.class_info(:SimpleExpressions)
        end

        it "recognizes inclusive ranges" do
            analyzed = @simple.method_info(:range_inclusive)
            assert_known_class Range, analyzed.local_variable_get(:a, 0)
        end
        it "recognizes exclusive ranges" do
            analyzed = @simple.method_info(:range_exclusive)
            assert_known_class Range, analyzed.local_variable_get(:a, 0)
        end

        it "recognizes captures" do
            analyzed = @simple.method_info(:regexp_capture)
            assert_known_class String, analyzed.local_variable_get(:a, 0)
        end
        it "recognizes back-references" do
            analyzed = @simple.method_info(:regexp_backref)
            assert_known_class String, analyzed.local_variable_get(:a, 0)
        end
        it "recognizes hash literals" do
            analyzed = @simple.method_info(:hash)
            assert_known_class Hash, analyzed.local_variable_get(:a, 0)
        end
    end
end

