require_relative 'test_helper'

module Typo
    describe "accessors" do
        before do
            @analyzer = Analyze.file(File.expand_path("attr.rb", __dir__))
            @attr = @analyzer.class_info(:Attr)
        end

        it "recognizes the link between attr_reader and the ivar" do
            assert_same @attr.instance_variable_get(:@reader),
                @attr.method_info(:reader).return_type
        end

        it "recognizes the link between attr_writer and the ivar" do
            assert_same @attr.instance_variable_get(:@writer),
                @attr.method_info(:writer=).return_type
            assert_same @attr.instance_variable_get(:@writer),
                @attr.method_info(:writer=).argument_types[0]
        end

        it "recognizes the link between attr_accessor and the ivar" do
            assert_same @attr.instance_variable_get(:@accessor),
                @attr.method_info(:accessor).return_type
            assert_same @attr.instance_variable_get(:@accessor),
                @attr.method_info(:accessor=).return_type
            assert_same @attr.instance_variable_get(:@accessor),
                @attr.method_info(:accessor=).argument_types[0]
        end
    end
end
