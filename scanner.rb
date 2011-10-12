require "token"

class Scanner
  STD_ERR_MESSAGE = "Invalid argument '.chr' on line: .line_number"
  MALFORMED_STRING = "Malformed string on line: .line_number"
  
  attr_reader :file
  attr_accessor :eof, :line_info, :tokens
  
  def initialize(file_name = "")
    @file = File.open(file_name.to_s)
    @line_info = { :line_position => 0, :line_number => 1, :line => file.gets }
    @eof = false
    @tokens = []
    scan
  end
  
  private  
  #TODO This class will define that the token will follow
  class Automata; end
    
  #TODO Try to put everything that is related to the file in the source code class.
  class SourceCode; end

  # Get the next character in the source code.
  # In case it reached the last line returns the constant :end_of_file.
  def get_next_char
    update_line_info

    if line_info[:line]
      line_info[:line][line_info[:line_position]].chr
    else
      self.eof = true
      :end_of_file
    end
  end

  # Subtract 1 from the line position unless it is the end of file.
  def unget_next_char
    self.line_info[:line_position] -= 1 unless eof
  end
  
  def update_line_info
    if !eof && line_info[:line_position].eql?(line_info[:line].length - 1)
      self.line_info[:line_position] = 0
      self.line_info[:line_number] = line_info[:line_number] ? line_info[:line_number] + 1 : 1
      self.line_info[:line] = file.gets
    else
      self.line_info[:line_position] += 1
    end    
  end

  def scan
    chr = line_info[:line][line_info[:line_position]].chr
    
    while chr != :end_of_file
      token = Token.new
      state = :start
      heap = {}
      equal_open = 0
      equal_close = 0
      while state != :final
        case state
        when :start
          if    chr.match(/[_a-zA-Z]/)
            heap[:identifier] = heap[:identifier] ? heap[:identifier] + chr : chr
            state = :in_identifier
          elsif chr.match(/\d/) 
            heap[:number] = heap[:number] ? heap[:number] + chr : chr
            state = :in_number
          elsif chr.eql?('=')
            state = :in_eql
          elsif chr.eql?('~')
            state = :in_diff
          elsif chr.eql?('<')
            state = :in_lthan
          elsif chr.eql?('>')
            state = :in_gthan
          elsif chr.eql?('.')
            state = :in_dot
          elsif chr.eql?('[')
            state = :in_open_square_bracket
          elsif chr.eql?('\'') 
            heap[:string] = heap[:string] ? heap[:string] + chr : ''
            state = :in_single_quoted_string
          elsif chr.eql?('"') 
            heap[:string] = heap[:string] ? heap[:string] + chr : ""
            state = :in_double_quoted_string
          elsif chr.eql?('-')           then state = :in_hyfen
          else
            if chr.match(/[\s|\t|\n]/)  then state = :start
            elsif chr.eql?('+')         then token.update_attributes(:line_number => line_info[:line_number], :type => :addition)
            elsif chr.eql?('*')         then token.update_attributes(:line_number => line_info[:line_number], :type => :multiplication)
            elsif chr.eql?('/')         then token.update_attributes(:line_number => line_info[:line_number], :type => :division)
            elsif chr.eql?('%')         then token.update_attributes(:line_number => line_info[:line_number], :type => :module)
            elsif chr.eql?('^')         then token.update_attributes(:line_number => line_info[:line_number], :type => :exponetiation)
            elsif chr.eql?('#')         then token.update_attributes(:line_number => line_info[:line_number], :type => :hashtag)
            elsif chr.eql?('(')         then token.update_attributes(:line_number => line_info[:line_number], :type => :open_parentheses)
            elsif chr.eql?(')')         then token.update_attributes(:line_number => line_info[:line_number], :type => :close_parentheses)
            elsif chr.eql?('{')         then token.update_attributes(:line_number => line_info[:line_number], :type => :open_brackets)
            elsif chr.eql?('}')         then token.update_attributes(:line_number => line_info[:line_number], :type => :close_brackets)
            elsif chr.eql?(']')         then token.update_attributes(:line_number => line_info[:line_number], :type => :close_sbrackets)
            elsif chr.eql?(';')         then token.update_attributes(:line_number => line_info[:line_number], :type => :semi_colon)
            elsif chr.eql?(',')         then token.update_attributes(:line_number => line_info[:line_number], :type => :comma)
            else
              raise standard_error_message(chr, line_info[:line_number])
            end
            state = :final
          end
        when :in_identifier
          if !(chr.match(/[_a-zA-Z0-9]/))
            token.update_attributes(:line_number => line_info[:line_number], :type => :identifier, :value => heap[:identifier].strip)
            heap.delete :identifier
            state = :final
            unget_next_char
          else
            heap[:identifier] += chr
          end          
        when :in_hyfen
          if chr.eql?('-')
            state = :in_comment
          else
            token.update_attributes(:line_number => line_info[:line_number], :type => :subtraction)
            unget_next_char
            state = :final
          end
        when :in_eql
          if chr.eql?('=') 
            token.update_attributes(:line_number => line_info[:line_number], :type => :comparison)
          else
            token.update_attributes(:line_number => line_info[:line_number], :type => :assign)
            unget_next_char
          end
          state = :final
        when :in_diff
          if t.eql?('=')
            token.update_attributes(:line_number => line_info[:line_number], :type => :difference)
            state = :final
          else
            raise standard_error_message(chr)
          end
        when :in_lthan
          if chr.eql?('=')
            token.update_attributes(:line_number => line_info[:line_number], :type => :lower_equal_than)
          else
            token.update_attributes(:line_number => line_info[:line_number], :type => :lower_than)
            unget_next_char
          end
          state = :final
        when :in_gthan
          if chr.eql?('=')
            token.update_attributes(:line_number => line_info[:line_number], :type => :greater_equal_than)
          else
            token.update_attributes(:line_number => line_info[:line_number], :type => :greater_than)
            unget_next_char
          end
          state = :final          
        when :in_dot
          if chr.match(/[^\.]/)
            token.update_attributes(:line_number => line_info[:line_number], :type => :dot)
            unget_next_char
            state = :final
          else
            state = :in_double_dot
          end
        when :in_double_dot
          if chr.match(/[^\.]/)
            token.update_attributes(:line_number => line_info[:line_number], :type => :concatenation)
            unget_next_char
          else
            token.update_attributes(:line_number => line_info[:line_number], :type => :list)
          end
        when :in_open_square_bracket
          if chr.eql?('=')
            equal_open = equal_open ? equal_open + 1 : 1
            state = :in_open_string
          elsif chr.eql?('[')
            equal_open = 0
            state = :in_block_string
          else
            token.update_attributes(:line_number => line_info[:line_number], :type => :open_sbrackets)
            state = :final
          end
        when :in_block_string
          heap[:string] = heap[:string] ? heap[:string] + chr : chr
          state = :in_close_string if chr.eql?(']')
        when :in_open_string
          if chr.eql?('=')
            equal_open += 1
            state = :in_open_string
          elsif chr.eql?('[')
            state = :in_block_string
          else
            state = :in_close_string
          end
        when :in_close_string
          if chr.match(/[^\=\]]/)
            heap[:string] = chr
            state = :in_block_string
          elsif chr.eql?('=')
            equal_close += 1
          elsif chr.eql?(']')
            if equal_open == equal_close
              heap[:string].slice!(heap[:string].length - 1)
              token.update_attributes(:line_number => line_info[:line_number], :type =>  :string, :value => heap[:string].strip)
              heap.delete :string
              state = :final
            else
              raise malformed_string(line_info[:line_number])
            end
          end
        when :in_single_quoted_string
          heap[:string] += chr
          if chr.eql?('\'')
            token.update_attributes(:line_number => line_info[:line_number], :type => :string, :value => heap[:string].strip)
            state = :final
          elsif chr.eql?("\n")
            raise malformed_string(line_info[:line_number])
          end
        when :in_double_quoted_string
          heap[:string] += chr
          if chr.eql?('"')
            heap[:string].slice!(heap[:string].length - 1)
            token.update_attributes(:line_number => line_info[:line_number], :type => :string, :value => heap[:string].strip)
            heap.delete :string
            state = :final
          elsif chr.eql?("\n")
            raise malformed_string(line_info[:line_number])
          end
        when :in_number
          if chr.match(/\D/)
            if chr.eql?('.')
              state = :in_dec_number
              dot = chr # TODO Verify why we are using this!
            elsif chr.eql?('x')
              state = :in_hex_number
            elsif chr.match(/\w/) && chr.match(/[^x]/)
              state = :in_not_number
            else
              token.update_attributes(:line_number => line_info[:line_number], :type => :number, :value => heap[:number].strip)
              heap.delete :number
              state = :final
              unget_next_char
            end
          else
            heap[:number] += chr
          end
        when :in_dec_number
          if chr.match(/\D/)
            if dot.eql?('.')
              dot = '' # TODO Verify why we are using this!
              raise standard_error_message(chr, line_info[:line_number])
            elsif chr.match(/e/i)
              state = :in_exponential_number
            elsif chr.match(/\w/)
              state = :in_not_number
            else
              raise standard_error_message(chr, line_info[:line_number])
            end
          else
            heap[:number] += chr
          end
        when :in_hex_number
          if chr.match(/\D/)
            if chr.match(/[a-f]/i)
              state = :in_hex_number
            elsif chr.match(/[^a-f]/i)
              state = :in_not_number
            else
              raise "Malformed hexadecimal number"
            end
          else
            heap[:number] += chr  
          end
        when :in_exp_number
          if t.match(/\D/)
            if t.match(/\-/)
              state = :in_exp_number
            elsif t.match(/\w/)
              state = :in_not_number
            else
              raise "Malformed exponential number"
            end
          else
            heap[:number] += chr
          end
        when :in_not_number
          raise standard_error_message(chr, line_info[:line_number]) if chr.match(/[\s\t\n\r\0]/)
        when :in_comment
          if chr.eql?('[') then state = :in_block_comment
          else                  state = :in_inline_comment
          end
        when :in_inline_comment
          state = :final if chr.eql?("\n")
        when :in_block_comment
          if chr.eql?('=')
            equal_open += 1
            state = :in_open_block_comment
          elsif chr.eql?('[')
            equal_open = 0
            state = :in_word_block_comment
          else
            equal_open = 0
            state = :in_inline_comment
          end
        when :in_open_block_comment
          if chr.eql?('=')
            equal_open += 1
            state = :in_open_block_comment
          elsif chr.eql?('[')
            state = :in_word_block_comment
          else
            state = :in_inline_comment
          end
        when :in_word_block_comment
          state = :in_close_block_comment if chr.eql?(']')
        when :in_close_block_comment
          if chr.match(/[^\=\]]/)
            state = :in_word_block_comment
          elsif chr.eql?('=')
            equal_close += 1
          elsif chr.eql?(']')
            if equal_open == equal_close
              state = :final
            else
              equal_close = 0
              state = :in_word_block_comment
            end
          end
        end
        
        chr = get_next_char

        if chr.eql?(:end_of_file)
          token.update_attributes(:line_number => line_info[:line_number], :type => :end_of_file)
          state = :final          
        end
      end
     
      token.update_if(:reserved_word) || token.update_if(:special_symbol)
      self.tokens.push(token) if !token.type.nil?
    end
  end
  
  def standard_error_message(chr, line_number)
    STD_ERR_MESSAGE.gsub('.chr', chr.to_s).gsub('.line_number', line_number.to_s)
  end
  
  def malformed_string(line_number)
    MALFORMED_STRING.gsub('.line_number', line_number.to_s)
  end
end