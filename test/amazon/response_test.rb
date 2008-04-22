require File.join(File.dirname(__FILE__), '../test_helper')

class Amazon::A2s::ResponseTest < Test::Unit::TestCase
  def test_doc_is_directly_accessible
    resp = Amazon::A2s::Response.new("junk.com", "<p>Hello some <em>nested</em> html</p>")
    assert_equal resp.text_at(:em), 'nested'
    assert_equal resp.text_at(:em), resp.doc.text_at(:em)
  end
end
