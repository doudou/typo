require_relative 'test_helper'

module Typo
    describe "instance variables" do
        include Helpers

        before do
            @analyzer = Analyze.file(File.expand_path("ivar.rb", __dir__))
            @ivar = @analyzer.class_info(:IVar)
        end

        it "updates the ivar type on write" do
            ivar = @ivar.instance_variable_get(:@assign)
            assert_constant 42, ivar
        end

        it "updates the ivar type on call" do
            ivar = @ivar.instance_variable_get(:@call)
            assert_would_respond_to :test, ivar
        end

        it "accumulates information on a single ivar" do
            ivar = @ivar.instance_variable_get(:@common)
            assert_would_respond_to :first, ivar
            assert_would_respond_to :second, ivar
        end
    end
end

