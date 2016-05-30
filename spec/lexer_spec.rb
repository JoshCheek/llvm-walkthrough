require 'kaleidoscope/lexer'

# http://llvm.org/docs/tutorial/LangImpl1.html#language
RSpec.describe Kaleidoscope::Lexer do
  specify 'input is a stream of characters, output is a stream of tokens'
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

