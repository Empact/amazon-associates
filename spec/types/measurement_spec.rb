require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "measurement object", :shared => true do
  it "should take a quantity and units" do
    m = measurement_with(:value => 11.3, :units => 'inches')
    m.value.should == 11.3
    m.units.should == 'inches'
  end

  it "should default units to 'pixels', as we use it mostly for images" do
    m = measurement_with(:value => 22.19)
    m.value.should == 22.19
    m.units.should == 'pixels'
  end

  it "should translate 'hundredths-' units to standard quantities" do
    m = measurement_with(:value => 1130, :units => 'hundredths-inches')
    m.value.should == 11.3
    m.units.should == 'inches'
  end
end

describe Amazon::Associates::Measurement do
  describe "#initialize" do
    def measurement_with(opts)
      Amazon::Associates::Measurement.new(*opts.values_at(:value, :units).compact)
    end

    it_should_behave_like "measurement object"
  end

  describe "#from_xml" do
    def measurement_with(opts)
      doc = ROXML::XML::Document.new
      doc.root = ROXML::XML::Node.new('width', opts[:value].to_s)
      doc.root['Units'] = opts[:units] unless opts[:units].blank?
      Amazon::Associates::Measurement.from_xml(doc.root)
    end

    it_should_behave_like "measurement object"
  end
end