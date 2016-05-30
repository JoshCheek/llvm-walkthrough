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
      chars = next_token(stream)
      if chars.empty? && stream.eof?
        [:eof]
      elsif chars == 'def'
        [:def, chars]
      elsif chars == 'extern'
        [:extern, chars]
      elsif chars[0] == '#'
        [:comment, chars]
      elsif chars =~ /[a-z]/
        [:identifier, chars]
      elsif chars =~ /\d/
        [:number, chars.to_f]
      else
        [:operator, chars]
      end
    end

    def next_token(stream)
      if peek(stream) == '#'
        return next_comment(stream)
      end

      chars = ""
      until stream.eof?
        char = stream.getc
        if char =~ /\s/
          stream.ungetc char
          break
        elsif operator?(char) && chars.empty?
          chars << char
          break
        elsif operator?(char)
          stream.ungetc char
          break
        else
          chars << char
        end
      end
      chars
    end

    def remove_whitespace(stream)
      take_while(stream) { |char| char =~ /\s/ }
    end

    def next_comment(stream)
      take_while(stream) { |char| char != "\n" }
    end

    OPERATORS = %w[+ - ( )].map(&:freeze)

    def operator?(string)
      OPERATORS.include? string
    end

    def peek(stream)
      char = stream.getc
      stream.ungetc char
      char
    end

    def take_while(stream)
      taken = ""
      until stream.eof?
        char = stream.getc
        if yield char
          taken << char
        else
          stream.ungetc char
          break
        end
      end
      taken
    end
  end
end
