require 'test_helper'

module Typo
    describe AnyType do
        before do
            @any = AnyType.new
        end

        it "narrows to its argument" do
            type = flexmock
            assert_same type, @any.narrow(type)
        end

        it "is compatible with any type" do
            assert @any.compatible_with_type?(flexmock)
        end

        it "is compatible with any value" do
            assert @any.compatible_with_value?(flexmock)
        end
    end
end

