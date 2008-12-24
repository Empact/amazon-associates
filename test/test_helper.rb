require 'test/unit'
require 'rubygems'
require 'extensions/object'
require 'ruby-debug'
require File.join(File.dirname(__FILE__), '../lib/amazon-associates')

AWS_ACCESS_KEY_ID = '0PP7FTN6FM3BZGGXJWG2'
raise "Please specify set your AWS_ACCESS_KEY_ID" if AWS_ACCESS_KEY_ID.empty?

Amazon::Associates.options.merge!(
  :aws_access_key_id => AWS_ACCESS_KEY_ID)
