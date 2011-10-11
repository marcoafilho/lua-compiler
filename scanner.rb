require "token"

# Steps for building the scanner
# 001: Read the entire file as one string buffer
# 002: Create finite automata in order to generate tokens
# 002.1: The object is to loop through the automata until get to a done state
# 002.2: In case of a automata gets into a non final state it should throw an error
# 003: When the token reaches its final state save it into a reserved symbol table
# 004: In cases of multiline code, like comments and strings we should create a heap to handle that


class Scanner
  attr_reader :file
  attr_accessor :eof, :line_info, :tokens
  
  def initialize(file_name = "")
    @file = File.open(file_name.to_s)
    @line_info = { :line_position => 0, :line_number => 1, :line => file.gets }
    @eof = false
    @tokens = { :line_number => 0, :type => "", :value => "" }
    scan
  end
  
  private
  
  #TODO This class will define that the token will follow
  class Automata;
    attr_accessor :states
  end
  
  #TODO Try to put everything that is related to the file in the source code class.
  class SourceCode;end

  def get_next_char
    update_line_info

    if line_info[:line] # End of file checking
      line_info[:line][line_info[:line_position]].chr
    else
      self.eof = true
      :end_of_file
    end
  end

  def unget_next_char
    self.line_info[:line_position] -= 1 if !eof
  end
  
  def update_line_info
    if line_info[:line_position].eql?(line_info[:line].length - 1)
      self.line_info[:line_position] = 0
      self.line_info[:line_number] = line_info[:line_number] ? line_info[:line_number] + 1 : 1
      self.line_info[:line] = file.gets
    else
      self.line_info[:line_position] += 1
    end    
  end
  
  def reserved_word(token_string)
    token = Token::TOKEN_TYPE.find_index(token_string)
    token.nil? ? token_string : token
  end

  def scan
    analyse
  end

  def analyse
    current_char = nil
    
    while current_char != :end_of_file

      print current_char = get_next_char
    end
  end
end