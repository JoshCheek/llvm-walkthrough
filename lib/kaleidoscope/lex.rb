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

    def self.symbol_list!(list)
      list.freeze.each &:freeze
    end
    OPERATORS = symbol_list! %w[+ - ( ) < >]
    KEYWORDS  = symbol_list! %w[def extern if then else]

    attr_accessor :stream

    def take_token(stream)
      take_whitespace(stream)
      case peek(stream)
      when nil         then [:eof]
      when '#'         then [:comment,  take_comment(stream)]
      when /[0-9]/     then [:number,   take_number(stream).to_f]
      when *OPERATORS  then [:operator, take_operator(stream).intern]
      else
        chars = take_alpha(stream)
        not_empty! chars, stream
        case chars
        when *KEYWORDS then [:keyword,    chars.intern]
        else                [:identifier, chars.intern]
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

    def peek(stream)
      char = stream.getc
      stream.ungetc char
      char
    end

    def not_empty!(chars, stream)
      return unless chars.empty?
      raise "Empty! next up: #{stream.gets.inspect}"
    end
  end
end
