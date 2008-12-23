require File.join(File.dirname(__FILE__), '../test_helper')

class Amazon::A2s::MeasurementTest < Test::Unit::TestCase
  def test_new
    m = Amazon::A2s::Measurement.new(11.3, 'inches')
    assert_equal 11.3, m.value
    assert_equal 'inches', m.units
  end

  def test_new_with_default_units
    m = Amazon::A2s::Measurement.new(11.3)
    assert_equal 11.3, m.value
    assert_equal 'pixels', m.units
  end

  def test_hundredths_support_with_literal_args
    m = Amazon::A2s::Measurement.new(1130, 'hundredths-inches')
    assert_equal 11.3, m.value
    assert_equal 'inches', m.units
  end

  def test_hundredths_support_with_xml_arg
    doc = ROXML::XML::Document.new
    doc.root = ROXML::XML::Node.new_element('width', '1130')
    doc.root['Units'] = 'hundredths-inches'
    m = Amazon::A2s::Measurement.from_xml(doc.root)
    assert_equal 11.3, m.value
    assert_equal 'inches', m.units
  end
end