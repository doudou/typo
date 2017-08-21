$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "typo"

begin
    require 'pry'
    require 'pry/byebug'
rescue LoadError
end

require "minitest/spec"
require 'flexmock/minitest'
FlexMock.partials_are_based = true
FlexMock.partials_verify_signatures = true
require "minitest/autorun"
