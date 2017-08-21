require 'method_source'
require 'parser/current'
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

require "typo/version"
require "typo/exceptions"
require 'typo/constraint'
require 'typo/constant'
require 'typo/any_type'
require 'typo/known_class'
require 'typo/method_analysis'

require 'typo/analyze'

module Typo
end
