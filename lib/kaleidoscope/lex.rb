module Kaleidoscope
  class Lex
    def self.call(stream)
      new(stream).call.to_a
    end

    def initialize(stream)
      self.stream = stream
    end

    def call
      return to_enum :call unless block_given?
      yield get_token until stream.eof?
    end

    private

    attr_accessor :stream

    def get_token
      token = ""
      token << stream.getc
      token << stream.getc
      token << stream.getc
      [:def, token]
    end
  end
end
