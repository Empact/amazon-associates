require "rubygems"
require "test/unit"
require "shoulda"
require "mocha"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , 'utilities'))
require 'amazon-associates'
require 'filesystem_test_helper'