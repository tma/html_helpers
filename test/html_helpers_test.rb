require "test/unit"
require "action_view"
require "htmlentities"
require "html_helpers"
class HtmlEntityCoderTest < Test::Unit::TestCase
  include HTML::EntityCoder

  def test_basic_encoding
    assert_equal encode_entities("This is <em>emphasized</em>!"),
                                 "This is &lt;em&gt;emphasized&lt;/em&gt;!"
  end

  def test_basic_decoding
    assert_equal decode_entities("This is &lt;em&gt;emphasized&lt;/em&gt;!"),
                                 "This is <em>emphasized</em>!"
  end

  def test_decoding_numeric_entities
    assert_equal decode_entities("This is &#60;em&#62;emphasized&#60;/em&#62;!"),
                                 "This is <em>emphasized</em>!"
  end

  def test_decoding_hex_entities
    assert_equal decode_entities("This is &#x3C;em&#x3E;emphasized&#x3C;/em&#x3E;!"),
                                 "This is <em>emphasized</em>!"
  end

  def test_decoding_mixed_entities
    assert_equal decode_entities("This is &lt;em&#x3E;emphasized&lt;/em&#62;!"),
                                 "This is <em>emphasized</em>!"
  end

  def test_text_encoding
    test_str = "Zufl&uuml;sse entw&auml;ssert.\nau&szlig;erdem kr&auml;ftige."
    assert_equal "UTF-8", test_str.encoding.name

    answer_str = encode_entities("Zuflüsse entwässert.\naußerdem kräftige.")
    assert_equal "UTF-8", answer_str.encoding.name

    assert_equal  answer_str, test_str
  end

  def test_text_decoding
    test_str = "Zuflüsse entwässert.\naußerdem kräftige."
    assert_equal "UTF-8", test_str.encoding.name
    
    answer_str = decode_entities("Zufl&uuml;sse entw&auml;ssert.\nau&szlig;erdem kr&auml;ftige.")
    assert_equal "ISO-8859-1", answer_str.encoding.name
    
    assert_equal test_str, answer_str.encode("UTF-8")
    assert_equal "Zuflüsse entwässert.\naußerdem kräftige.".encode("ISO-8859-1"), answer_str
  end
  
  def test_named_entity_decoding
    assert_equal [146, 34, 148], decode_entities("&rsquo;&quot;&rdquo;").bytes.to_a
  end

  def test_string_encoding
    test_str = "Michael&rsquo;s degree is in &quot;ICS&quot;"
    assert_equal 'UTF-8', test_str.encoding.name

    answer_str = decode_entities(test_str)
    
    assert_equal "ISO-8859-1", answer_str.encoding.name
    # assert_equal "Michael’s degree is in \"ICS\"".encode("ISO-8859-1"), answer_str
  end
  
  def test_ndash_encoding
    test_str = "&deg;&ndash;"
    assert_equal 'UTF-8', test_str.encoding.name 

    answer_str = decode_entities(test_str)
    assert_equal 'ISO-8859-1', answer_str.encoding.name 

    assert_equal [176, 150], answer_str.bytes.to_a
  end
end
