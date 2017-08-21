require 'test_helper'

module Typo
    describe Constant do
        before do
            @constant = Constant.new(@constant_value = flexmock)
        end

        describe "#narrow" do
            it "narrows to itself after checking that the type is compatible with its value" do
                type = flexmock
                flexmock(@constant).should_receive(:compatible_with_type?).with(type).and_return(true)
                assert_same @constant, @constant.narrow(type)
            end
            it "refuses to be narrowed to a type that is not compatible with its value" do
                type = flexmock
                flexmock(@constant).should_receive(:compatible_with_type?).with(type).and_return(false)
                e = assert_raises(NarrowingIncompatibility) do
                    @constant.narrow(type)
                end
                assert_equal "#{@constant_value} is incompatible with #{type}, cannot narrow", e.message
            end
        end

        describe "#compatible_with_type?" do
            it "delegates to the type to check whether it is compatible with the constant's value" do
                type = flexmock
                type.should_receive(:compatible_with_value?).with(@constant_value).once.and_return(false)
                refute @constant.compatible_with_type?(type)
            end
            it "delegates to the type to check whether it is compatible with the constant's value" do
                type = flexmock
                type.should_receive(:compatible_with_value?).with(@constant_value).once.and_return(true)
                assert @constant.compatible_with_type?(type)
            end
        end

        describe "#compatible_with_value?" do
            it "checks if the value is equal to the constant's value" do
                @constant_value.should_receive(:==).with(value = flexmock).and_return(true).once
                assert @constant.compatible_with_value?(value)
            end
            it "checks if the value is equal to the constant's value" do
                @constant_value.should_receive(:==).with(value = flexmock).and_return(false).once
                refute @constant.compatible_with_value?(value)
            end
        end
    end
end

