require 'test/unit'
require 'rubygems'
require File.join(File.dirname(__FILE__), '../lib/amazon-a2s')

AWS_ACCESS_KEY_ID = '0PP7FTN6FM3BZGGXJWG2'
raise "Please specify set your AWS_ACCESS_KEY_ID" if AWS_ACCESS_KEY_ID.empty?

Amazon::A2s.options.merge!(
  :aws_access_key_id => AWS_ACCESS_KEY_ID)
