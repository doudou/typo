$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "typo"

require "minitest/spec"
require 'flexmock/minitest'
FlexMock.partials_are_based = true
FlexMock.partials_verify_signatures = true
require "minitest/autorun"

module Helpers
    def assert_is_any(type)
        assert type.any?
    end

    def assert_known_class(klass, type)
        assert type.has_known_class?(klass)
    end

    def assert_constant(value, type)
        assert type.has_known_value?(value)
    end

    def assert_would_respond_to(m, type)
        assert type.would_respond_to?(m)
    end

    def analyze_file(path)
        Analyze.analyze()
    end
end
