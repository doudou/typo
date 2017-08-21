require 'test_helper'

module Typo
    describe KnownClass do
        before do
            @superklass = Class.new
            @klass = Class.new(@superklass)
            @subklass = Class.new(@klass)
            @known_class = KnownClass.new(@klass)
        end

        describe "#narrow" do
            it "narrows to itself after checking that the type is compatible with the class" do
                type = flexmock
                flexmock(@known_class).should_receive(:compatible_with_type?).with(type).and_return(true)
                assert_same @known_class, @known_class.narrow(type)
            end
            it "refuses to be narrowed to a type that is not compatible with the class" do
                type = flexmock
                flexmock(@known_class).should_receive(:compatible_with_type?).with(type).and_return(false)
                e = assert_raises(NarrowingIncompatibility) do
                    @known_class.narrow(type)
                end
                assert_equal "#{@klass} is incompatible with #{type}, cannot narrow", e.message
            end
        end

        describe "#describes_class?" do
            it "is false if the argument is a superclass of the class" do
                refute @known_class.describes_class?(@superklass)
            end
            it "is true if the argument is the class" do
                assert @known_class.describes_class?(@klass)
            end
            it "is true if the argument is a subclass of the class" do
                assert @known_class.describes_class?(@subklass)
            end
            it "is false for an unrelated class" do
                refute @known_class.describes_value?(Class.new)
            end
        end

        describe "#compatible_with_type?" do
            it "delegates to the type to check whether it is compatible with the class" do
                type = flexmock
                type.should_receive(:describes_class?).with(@klass).once.and_return(false)
                refute @known_class.compatible_with_type?(type)
            end
            it "delegates to the type to check whether it is compatible with the class" do
                type = flexmock
                type.should_receive(:describes_class?).with(@klass).once.and_return(true)
                assert @known_class.compatible_with_type?(type)
            end
        end

        describe "#describes_value?" do
            it "true if the value is an instance of a subclass of the class" do
                assert @known_class.describes_value?(@subklass.new)
            end
            it "is true if the value is an instance of the class" do
                assert @known_class.describes_value?(@klass.new)
            end
            it "is false if the value is of a superclass of the class" do
                refute @known_class.describes_value?(@superklass.new)
            end
            it "is false if the value is of an unrelated class" do
                refute @known_class.describes_value?(Class.new.new)
            end
        end
    end
end


