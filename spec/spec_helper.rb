require File.join(File.dirname(__FILE__), "../lib/amazon-associates")

shared_examples_for "Amazon Associates response" do
  describe "request" do
    subject { @response.request }
    it { should be_valid }
  end
end