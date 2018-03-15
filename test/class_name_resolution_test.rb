require_relative 'test_helper'

module Typo
    describe "class and module name resolution" do
        before do
            @analyzer = Analyze.file(File.expand_path("class_name_resolution.rb", __dir__))
        end

        it "registers the M0 and M3 modules at the root" do
            assert @analyzer.root.fetch_constant(:M0).module?
            assert @analyzer.root.fetch_constant(:M3).module?
        end

        it "registers the M0::A and M0::A::B classes" do
            assert @analyzer.root.resolve_constant(:M0, :A).class?
            assert @analyzer.root.resolve_constant(:M0, :A, :B).class?
        end

        it "registers the M0::M1::C class" do
            assert @analyzer.root.resolve_constant(:M0, :M1, :C).class?
        end

        it "registers the M0::D class from M0::M2" do
            assert @analyzer.root.resolve_constant(:M0, :D).class?
        end

        it "registers the M0::M2::E::X class" do
            assert @analyzer.root.resolve_constant(:M0, :M2, :E, :X).class?
        end
    end
end

