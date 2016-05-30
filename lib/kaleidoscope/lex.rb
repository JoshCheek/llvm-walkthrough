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
        token = take_token(stream)
        yield token
        break if token[0] == :eof
      end
    end

    private

    attr_accessor :stream

    def take_token(stream)
      take_whitespace(stream)
      case peek(stream)
      when '#'
        [:comment, take_comment(stream)]
      when /[0-9]/
        [:number, take_number(stream).to_f]
      when *OPERATORS
        [:operator, take_operator(stream)]
      else
        case chars = take_alpha(stream)
        when ''
          raise unless stream.eof? # sanity check, no tests hit this
          [:eof]
        when 'def'
          [:def, chars]
        when 'extern'
          [:extern, chars]
        else
          [:identifier, chars]
        end
      end
    end

    def take_alpha(stream)
      take_while(stream) { |char| char =~ /\w/ }
    end

    def take_whitespace(stream)
      take_while(stream) { |char| char =~ /\s/ }
    end

    def take_comment(stream)
      take_while(stream) { |char| char != "\n" }
    end

    def take_operator(stream)
      count = 0
      take_while(stream) { |char| (count+=1) == 1 }
    end

    def take_number(stream)
      take_while(stream) { |char| char =~ /[0-9.]/ }
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
