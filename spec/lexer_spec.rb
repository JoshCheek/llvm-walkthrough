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

  xspecify 'input is a stream of characters, output is a stream of tokens' do
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
    assert_lexes input, [
      [:comment,     "# Compute the x'th fibonacci number."],
      [:def,         "def"],
      [:identifier,  "fib"],
      [:operator,    "("],
      [:identifier,  "x"],
      [:operator,    ")"],
      [:conditional, "if"],
      [:identifier,  "x"],
      [:operator,    "<"],
      [:number,      "3"],
      [:ifbranch,    "then"],
      [:number,      "1"],
      [:ifbranch,    "else"],
      [:identifier,  "fib"],
      [:operator,    "("],
      [:identifier,  "x"],
      [:operator,    "-"],
      [:number,      "1"],
      [:operator,    ")"],
      [:operator,    "+"],
      [:identifier,  "fib"],
      [:operator,    "("],
      [:identifier,  "x"],
      [:operator,    "-"],
      [:number,      "2"],
      [:operator,    ")"],
      [:comment,     "# This expression will compute the 40th number."],
      [:identifier,  "fib"],
      [:operator,    "("],
      [:number,      "40"],
      [:operator,    ")"],
      [:eof]
    ]
  end

  describe 'recognized tokens' do
    specify 'def, when it sees the "def" alphabetic token' do
      assert_lexes "def", [[:def, "def"]]
    end

    specify 'extern, when it sees the "extern" alphabetic token' do
      assert_lexes "extern", [[:extern, "extern"]]
    end

    specify 'identifier, when it sees an alphabetic that is not a keyword' do
      assert_lexes "abc", [[:identifier, "abc"]]
    end

    specify 'number, (as a double), when it sees [0-9]+(\.[0-9]+)?' do
      assert_lexes "0",          [[:number, 0.0]]
      assert_lexes "1234567890", [[:number, 1234567890.0]]
      assert_lexes "0.0",        [[:number, 0.0]]
      assert_lexes "12.0",       [[:number, 12.0]]
      assert_lexes "12.34",      [[:number, 12.34]]
    end

    specify 'operator, when it\'s not alphanumeric' do
      assert_lexes "+", [[:operator, "+"]]
      assert_lexes "-", [[:operator, "-"]]
      assert_lexes "(", [[:operator, "("]]
      assert_lexes ")", [[:operator, ")"]]
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
      assert_lexes "1 + 2", [[:number, 1.0], [:operator, "+"], [:number, 2.0]]
      assert_lexes "1+2",   [[:number, 1.0], [:operator, "+"], [:number, 2.0]]
    end
  end
end

