require File.join(File.dirname(__FILE__), "../lib/amazon-associates")

Amazon::Associates.options.merge!(
  associate_tag: ENV['AMAZON_ASSOCIATE_TAG'], aws_access_key_id: ENV['AMAZON_ACCESS_KEY_ID'])

shared_examples_for "Amazon Associates response" do
  describe "request" do
    subject { @response.request }
    it { should be_valid }
  end
end