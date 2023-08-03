module Blue
  class Lexer
    def initialize(input)
      @input = input
      @current_position = 0
      @next_position = 0
      @current_character = 0

      read_character
    end

    def next_token
      skip_whitespaces

      token = nil
      case @current_character
      when "("
        token = Token.new(@current_character, Token::LPAREN)
      when ")"
        token = Token.new(@current_character, Token::RPAREN)
      when "-"
        token = Token.new(@current_character, Token::MINUS)
      when "="
        token = Token.new(@current_character, Token::EQUALS)
      when "!"
        if next_character == "="
          b = @current_character
          read_character
          token = Token.new(b + @current_character, Token::NOT_EQUALS)
        else
          token = Token.new(@current_character, Token::BANG)
        end
      when "<"
        token = Token.new(@current_character, Token::LT)
      when ">"
        token = Token.new(@current_character, Token::GT)
      when "\""
        return Token.new(read_string, Token::STRING)
      when "\0"
        return Token.new("", Token::EOF)
      else
        if digit?(@current_character)
          return Token.new(read_number, Token::NUMBER)
        elsif letter?(@current_character)
          literal = read_identifier
          return Token.new(literal, Token.lookup_identifier(literal))
        else
          token = Token.new(@current_character, Token::ILLEGAL)
        end
      end

      read_character

      token
    end

    def read_character
      if @next_position >= @input.size
        @current_character = "\0"
      else
        @current_character = @input[@next_position]
      end

      @current_position = @next_position
      @next_position += 1
    end

    def next_character
      if @next_position >= @input.size
        "\0"
      else
        @input[@next_position]
      end
    end

    def read_number
      start_pos = @current_position
      while(digit?(@current_character))
        read_character
      end
      @input[start_pos...@current_position]
    end

    def read_identifier
      start_pos = @current_position
      while(letter?(@current_character))
        read_character
      end
      @input[start_pos...@current_position]
    end

    def read_string
      read_character
      start_pos = @current_position
      while(@current_character != "\"" && @current_character != "\0")
        read_character
      end
      str = @input[start_pos...@current_position]
      read_character
      str
    end

    def skip_whitespaces
      while(whitespace?(@current_character))
        read_character
      end
    end

    def whitespace?(character)
      character == " " || character == "\t" || character == "\n" || character == "\r"
    end

    def letter?(character)
      character == "_" || (character >= "a" && character <= "z") || (character >= "A" && character <= "Z")
    end

    def digit?(character)
      character >= "0" && character <= "9"
    end
  end
end
