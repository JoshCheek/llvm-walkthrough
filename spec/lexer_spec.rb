require 'kaleidoscope/lex'
require 'stringio'

# http://llvm.org/docs/tutorial/LangImpl1.html#language
RSpec.describe Kaleidoscope::Lex do
  def assert_lexes(program, expected_tokens)
    stream = StringIO.new program
    actual = described_class.call(stream)
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
    ]
  end

  describe 'recognized tokens' do
    specify 'def, when it sees the "def" alphabetic token'
    specify 'extern, when it sees the "extern" alphabetic token'
    specify 'identifier, when it sees an alphabetic that is not a keyword'
    specify 'number, when it sees [0-9]+(\.[0-9]+)?'
    specify 'operator, when it\'s not alphanumeric'
    specify 'eof, when there it hits C-D'
    it 'ignores whitespace'
  end
end

