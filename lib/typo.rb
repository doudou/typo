require 'method_source'
require 'parser/current'
Parser::Builders::Default.emit_lambda = true
Parser::Builders::Default.emit_procarg0 = true

require "typo/version"
require "typo/exceptions"
require 'typo/constraint'
require 'typo/type'
require 'typo/variable'
require 'typo/class_analysis'
require 'typo/method_analysis'

require 'typo/constraints/call'

require 'typo/state'
require 'typo/analyze'

module Typo
end
