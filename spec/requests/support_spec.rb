require 'spec_helper'

describe Amazon::Associates do
  describe ".prepare_url" do
    context "when a country is provided" do
      it "should adjust the top-level domain of the result" do
        Amazon::Associates::TLDS.each_pair do |country, tld|
          Amazon::Associates.send(:prepare_url, country: country).should =~ %r{http://ecs\.amazonaws\.#{tld}/onca/xml\?.+}
        end
      end
    end
  end
end