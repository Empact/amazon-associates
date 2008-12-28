require "rubygems"
require "test/unit"
require "shoulda"
require "mocha"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , 'utilities'))
require 'amazon-associates'
require 'filesystem_test_helper'

AWS_ACCESS_KEY_ID = '0PP7FTN6FM3BZGGXJWG2'
raise "Please specify set your AWS_ACCESS_KEY_ID" if AWS_ACCESS_KEY_ID.empty?

Amazon::Associates.options.merge!(
  :aws_access_key_id => AWS_ACCESS_KEY_ID)
