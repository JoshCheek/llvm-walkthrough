module Kaleidoscope
  class Lex
    def self.call(stream)
      new(stream).call.to_a
    end

    def initialize(stream)
      self.stream = stream
    end

    def call
      return to_enum(:call) unless block_given?
      loop do
        token = get_token(stream)
        yield token
        break if token[0] == :eof
      end
    end

    private

    attr_accessor :stream

    def get_token(stream)
      remove_whitespace(stream)
      chars = next_nonwhitespace(stream)
      if chars.empty? && stream.eof?
        [:eof]
      elsif chars == 'def'
        [:def, chars]
      elsif chars == 'extern'
        [:extern, chars]
      elsif chars =~ /[a-z]/
        [:identifier, chars]
      elsif chars =~ /\d/
        [:number, chars.to_f]
      else
        [:operator, chars]
      end
    end

    def remove_whitespace(stream)
      until stream.eof?
        char = stream.getc
        next if char =~ /\s/
        stream.ungetc char
        break
      end
    end

    def next_nonwhitespace(stream)
      chars = ""
      until stream.eof?
        char = stream.getc
        if char =~ /\s/
          stream.ungetc char
          break
        else
          chars << char
        end
      end
      chars
    end

  end
end
