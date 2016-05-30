require 'kaleidoscope/lex'
require 'stringio'

# http://llvm.org/docs/tutorial/LangImpl1.html#language
RSpec.describe Kaleidoscope::Lex do
  def assert_lexes(program, expected_tokens, implicit_eof: true)
    stream = StringIO.new program
    actual = described_class.call(stream)
    expected_tokens << [:eof] if implicit_eof
    expect(actual).to eq expected_tokens
  end

  specify 'input is a stream of characters, output is a stream of tokens' do
    input = <<-KALEIDOSCOPE
      # Compute the x'th fibonacci number.
      def fib(x)
        if x < 3 then
          1
        else
          fib(x-1)+fib(x-2)

      # This expression will compute the 40th number.
      fib(40)
    KALEIDOSCOPE

    expected = [
      [:comment,     "# Compute the x'th fibonacci number."],
      [:keyword,     :def],
      [:identifier,  :fib],
      [:operator,    :"("],
      [:identifier,  :x],
      [:operator,    :")"],
      [:keyword,     :if],
      [:identifier,  :x],
      [:operator,    :<],
      [:number,      3.0],
      [:keyword,     :then],
      [:number,      1.0],
      [:keyword,     :else],
      [:identifier,  :fib],
      [:operator,    :"("],
      [:identifier,  :x],
      [:operator,    :-],
      [:number,      1.0],
      [:operator,    :")"],
      [:operator,    :+],
      [:identifier,  :fib],
      [:operator,    :"("],
      [:identifier,  :x],
      [:operator,    :-],
      [:number,      2.0],
      [:operator,    :")"],
      [:comment,     "# This expression will compute the 40th number."],
      [:identifier,  :fib],
      [:operator,    :"("],
      [:number,      40.0],
      [:operator,    :")"],
      [:eof]
    ]

    assert_lexes input, expected, implicit_eof: false
  end

  describe 'recognized tokens' do
    describe 'keywords are a subset of alphabetic tokens' do
      example('def')    { assert_lexes "def",    [[:keyword, :def]] }
      specify('extern') { assert_lexes "extern", [[:keyword, :extern]] }
      specify('if')     { assert_lexes "if",     [[:keyword, :if]] }
      specify('then')   { assert_lexes "then",   [[:keyword, :then]] }
      specify('else')   { assert_lexes "else",   [[:keyword, :else]] }
    end

    specify 'identifier, when it sees an alphabetic that is not a keyword' do
      assert_lexes "abc", [[:identifier, :abc]]
    end

    specify 'number, (as a double), when it sees [0-9]+(\.[0-9]+)?' do
      assert_lexes "0",          [[:number, 0.0]]
      assert_lexes "1234567890", [[:number, 1234567890.0]]
      assert_lexes "0.0",        [[:number, 0.0]]
      assert_lexes "12.0",       [[:number, 12.0]]
      assert_lexes "12.34",      [[:number, 12.34]]
    end

    specify 'operator, when it\'s not alphanumeric' do
      assert_lexes "+", [[:operator, :+]]
      assert_lexes "-", [[:operator, :-]]
      assert_lexes "<", [[:operator, :<]]
      assert_lexes ">", [[:operator, :>]]
      assert_lexes "(", [[:operator, :"("]]
      assert_lexes ")", [[:operator, :")"]]
    end

    specify 'comment, when beginning with a #' do
      assert_lexes "# a",     [[:comment, "# a"]]
      assert_lexes " # a",    [[:comment, "# a"]]
      assert_lexes "# a\n\n", [[:comment, "# a"]]
    end

    specify 'eof, when there it hits C-D or when there is no more input' do
      assert_lexes "1", [[:number, 1.0], [:eof]], implicit_eof: false
    end

    it 'ignores whitespace' do
      assert_lexes "1 + 2", [[:number, 1.0], [:operator, :+], [:number, 2.0]]
      assert_lexes "1+2",   [[:number, 1.0], [:operator, :+], [:number, 2.0]]
    end
  end
end

