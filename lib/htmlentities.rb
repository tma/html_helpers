#
# HTML entity encoding and decoding for Ruby
#

module HTMLEntities
  
  class InstructionError < RuntimeError
  end

  module Data #:nodoc:

    #
    # MAP is a hash of all the HTML entities I could discover, as taken
    # from the w3schools page on the subject:
    # http://www.w3schools.com/html/html_entitiesref.asp
    # The format is 'entity name' => codepoint where entity name is given
    # without the surrounding ampersand and semicolon.
    #
    MAP = {
      'quot'      => 34,        'apos'      => 39,        'amp'       => 38,
      'lt'        => 60,        'gt'        => 62,        'nbsp'      => 160,
      'iexcl'     => 161,       'curren'    => 164,       'cent'      => 162,
      'pound'     => 163,       'yen'       => 165,       'brvbar'    => 166,
      'sect'      => 167,       'uml'       => 168,       'copy'      => 169,
      'ordf'      => 170,       'laquo'     => 171,       'not'       => 172,
      'shy'       => 173,       'reg'       => 174,       'trade'     => 153,
      'macr'      => 175,       'deg'       => 176,       'plusmn'    => 177,
      'sup2'      => 178,       'sup3'      => 179,       'acute'     => 180,
      'micro'     => 181,       'para'      => 182,       'middot'    => 183,
      'cedil'     => 184,       'sup1'      => 185,       'ordm'      => 186,
      'raquo'     => 187,       'frac14'    => 188,       'frac12'    => 189,
      'frac34'    => 190,       'iquest'    => 191,       'times'     => 215,
      'divide'    => 247,       'Agrave'    => 192,       'Aacute'    => 193,
      'Acirc'     => 194,       'Atilde'    => 195,       'Auml'      => 196,
      'Aring'     => 197,       'AElig'     => 198,       'Ccedil'    => 199,
      'Egrave'    => 200,       'Eacute'    => 201,       'Ecirc'     => 202,
      'Euml'      => 203,       'Igrave'    => 204,       'Iacute'    => 205,
      'Icirc'     => 206,       'Iuml'      => 207,       'ETH'       => 208,
      'Ntilde'    => 209,       'Ograve'    => 210,       'Oacute'    => 211,
      'Ocirc'     => 212,       'Otilde'    => 213,       'Ouml'      => 214,
      'Oslash'    => 216,       'Ugrave'    => 217,       'Uacute'    => 218,
      'Ucirc'     => 219,       'Uuml'      => 220,       'Yacute'    => 221,
      'THORN'     => 222,       'szlig'     => 223,       'agrave'    => 224,
      'aacute'    => 225,       'acirc'     => 226,       'atilde'    => 227,
      'auml'      => 228,       'aring'     => 229,       'aelig'     => 230,
      'ccedil'    => 231,       'egrave'    => 232,       'eacute'    => 233,
      'ecirc'     => 234,       'euml'      => 235,       'igrave'    => 236,
      'iacute'    => 237,       'icirc'     => 238,       'iuml'      => 239,
      'eth'       => 240,       'ntilde'    => 241,       'ograve'    => 242,
      'oacute'    => 243,       'ocirc'     => 244,       'otilde'    => 245,
      'ouml'      => 246,       'oslash'    => 248,       'ugrave'    => 249,
      'uacute'    => 250,       'ucirc'     => 251,       'uuml'      => 252,
      'yacute'    => 253,       'thorn'     => 254,       'yuml'      => 255,
      'OElig'     => 140,       'oelig'     => 156,       'Scaron'    => 138,
      'scaron'    => 154,       'Yuml'      => 255,       'circ'      => 136,
      'tilde'     => 152,       'ensp'      => 32,        'emsp'      => 32,
      'thinsp'    => 32,        'zwnj'      => 32,        'zwj'       => 32,
      'lrm'       => 145,       'rlm'       => 146,       'ndash'     => 150,
      'mdash'     => 151,       'lsquo'     => 145,       'rsquo'     => 146,
      'sbquo'     => 130,       'ldquo'     => 147,       'rdquo'     => 148,
      'bdquo'     => 132,       'dagger'    => 134,       'Dagger'    => 135,
      'hellip'    => 133,       'permil'    => 137,       'lsaquo'    => 139,
      'rsaquo'    => 155,       'euro'      => 128 
    }

    MIN_LENGTH = MAP.keys.map{ |a| a.length }.min
    MAX_LENGTH = MAP.keys.map{ |a| a.length }.max
    NAMED_ENTITY_REGEXP = /&([a-z]{#{MIN_LENGTH},#{MAX_LENGTH}});/i
    REVERSE_MAP = MAP.invert

    BASIC_ENTITY_REGEXP = /[<>'"&]/

    # UTF8_NON_ASCII_REGEXP = /[\x00-\x1f]|[\xc0-\xfd][\x80-\xbf]+/
    UTF8_NON_ASCII_REGEXP = /[\x00-\x1f]|[\xc2\xa0-\xc3\xbf]+/

    ENCODE_ENTITIES_COMMAND_ORDER = { 
      :basic => 0,
      :named => 1,
      :decimal => 2,
      :hexadecimal => 3
    }
  
  end
  
  #
  # Decode XML and HTML 4.01 entities in a string into their UTF-8
  # equivalents.  Obviously, if your string is not already in UTF-8, you'd
  # better convert it before using this method, or the output will be mixed
  # up.
  #
  # Unknown named entities are not converted
  #
  def decode_entities(string)
    return nil if string.nil?
    string.gsub(Data::NAMED_ENTITY_REGEXP) do |e| 
      base = e.gsub(/&|;/,'')
      (cp = Data::MAP[base]) ? [cp].pack('C') : e.to_s
    end.gsub(/&#([0-9]{1,7});|&#x([0-9a-f]{1,6});/i) { 
      $1 ? [$1.to_i].pack('C') : [$2.to_i(16)].pack('C')
    }.force_encoding("ISO-8859-1")
  end
  
  #
  # Encode codepoints into their corresponding entities.  Various operations
  # are possible, and may be specified in order:
  #
  # :basic :: Convert the five XML entities ('"<>&)
  # :named :: Convert non-ASCII characters to their named HTML 4.01 equivalent
  # :decimal :: Convert non-ASCII characters to decimal entities (e.g. &#1234;)
  # :hexadecimal :: Convert non-ASCII characters to hexadecimal entities (e.g. # &#x12ab;)
  #
  # You can specify the commands in any order, but they will be executed in
  # the order listed above to ensure that entity ampersands are not
  # clobbered and that named entities are replaced before numeric ones.
  #
  # If no instructions are specified, :basic will be used.
  #
  # Examples:
  #   encode_entities(str) - XML-safe
  #   encode_entities(str, :basic, :decimal) - XML-safe and 7-bit clean
  #   encode_entities(str, :basic, :named, :decimal) - 7-bit clean, with all
  #   non-ASCII characters replaced with their named entity where possible, and
  #   decimal equivalents otherwise.
  #
  # Note: It is the program's responsibility to ensure that the string
  # contains valid UTF-8 before calling this method.
  #
  def encode_entities(string, *instructions)
    output = nil
    if (instructions.empty?)
      instructions = [:basic] 
    else
      instructions = instructions.sort_by { |instruction| 
        Data::ENCODE_ENTITIES_COMMAND_ORDER[instruction] || 
        (raise InstructionError, "unknown encode_entities command `#{instruction.inspect}'")
      }
    end
    instructions.each do |instruction|
      case instruction
      when :basic
        # Handled as basic ASCII
        output = (output || string).gsub(Data::BASIC_ENTITY_REGEXP) {
          # It's safe to use the simpler [0] here because we know
          # that the basic entities are ASCII.
          c = Data::REVERSE_MAP[$&.unpack("U")[0]]
          '&' << (c || $&[0]) << ';'
        }
      when :named
        # Test everything except printable ASCII 
        output = (output || string).gsub(Data::UTF8_NON_ASCII_REGEXP) {
          cp = $&.unpack('U')[0]
          (e = Data::REVERSE_MAP[cp]) ?  "&#{e};" : $&
        }
      when :decimal
        output = (output || string).gsub(Data::UTF8_NON_ASCII_REGEXP) {
          "&##{$&.unpack('U')[0]};"
        }
      when :hexadecimal
        output = (output || string).gsub(Data::UTF8_NON_ASCII_REGEXP) {
          "&#x#{$&.unpack('U')[0].to_s(16)};"
        }
      end 
    end
    return output
  end
  
  extend self
  
end