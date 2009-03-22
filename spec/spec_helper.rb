require "lib/amazon-associates"

describe "Amazon Associates response", :shared => true do
  describe "request" do
    subject { @response.request }
    it { should be_valid }
  end
end