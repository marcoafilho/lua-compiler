require "token"

class Scanner
  attr_reader :file
  attr_accessor :tokens
  
  attr_accessor :current_char, :line_position, :line_number, :line, :eof
  
  def initialize(file_name = "")
    @file = File.open(file_name.to_s)
    @tokens = []
    scan
  end
  
  private
  
    def reserved_word(token_string)
      token = Token::TOKEN_TYPE.find_index(token_string)
      token.nil? ? token_string : token
    end
    
    def scan
      scanned_file = file
      
      while line = scanned_file.gets
        puts scan_line
      end
    end
  
    def scan_line
      self.line_number = line_number ? line_number + 1 : 1
      self.line = file.gets
      self.line_position = 0
      
      #TODO Outputs the scanned line
      analyse(line, line_number)
    end
    
    def analyse(line, line_number)
      t = line[line_position].chr
      state = :start
      current_token = nil
      token_string = ""
      
      while state != :done
        save = 1
        case state
        when :start then
          if(t.match(/\d/))
            state = :innum
          elsif(t.match(/[_|\w]/))
            state = :inid
          elsif(t == :eof)
            state = :done
            current_token = :eof
            save = 0
          elsif(t.match(/\=/))
            state = :ineql
          elsif(t.match(/\~/))
            state = :indiff
          elsif(t.match(/</))
            state = :inlower_than
          elsif(t.match(/>/))
            state = :ingreater_than
          elsif(t.match(/./))
            state = :indot
          elsif(t.match(/\'/))
            state = :instring
          elsif(t.match(/\"/))
            state = :indouble_string
          elsif(t.match(/\[/))
            state = :in_square_bracket            
          elsif(t.match(/\-/))
            state = :in_hyfen
          else
            save = 0
            state = :done
            case(t)
            when ' ' | '\t' | '\n' then state = :start
            when '+' then current_token = :plus
            when '*' then current_token = :mult
            when '/' then current_token = :div
            when '%' then current_token = :mod
            when '^' then current_token = :circ
            when '#' then current_token = :hash
            when '(' then current_token = :lp
            when ')' then current_token = :rp
            when ']' then current_token = :rsb
            when '{' then current_token = :lb
            when '}' then current_token = :rb
            when ';' then current_token = :scol
            when ',' then current_token = :com
            else 
              current_token = :error
              state = :done
            end
          end
        when :innum
          if t.match(/\D/)
            if t.match(/\./)
              state = :in_decimal_number
              dot = t
            elsif t.match(/x/)
              state = :in_hex_number
            elsif t.match(/[^x]/)
              state = :in_not_number
            else
              current_token = :number
              state = :done
              unget_next_char
              save = 0
            end
          end
        when :in_decimal_number
          if t.match(/\D/)
            if dot.match(/\./)
              current_token = :error
              state = :done
              dot = ' '
            elsif t.match(/e/i)
              state = :in_exponential_number
            elsif t.match(/\w/)
              state = :in_not_number
            else
              current_token = :error
              state = :done
              unget_next_char
              save = 0
            end
          end
        when :in_exponential_number
          if t.match(/\D/)
            if t.match(/\-/)
              state = :in_exponential_number
            elsif t.match(/\w/)
              state = :in_not_number
            else
              current_token = :number
              state = :done
              unget_next_char
              save = 0
            end
          end
        when :in_hex_number
          if t.match(/\D/)
            if t.match(/[a-f]/i)
              state = :in_hex_number
            elsif t.match(/[^a-f]/i)
              state = :in_not_number
            else
              current_token = :number
              state = :done
              unget_next_char
              save = 0
            end
          end
        when :in_hyfen
          if t.match(/\-/)
            state = :in_comment
          else
            current_token = :min
            state = :done
          end
        when :in_comment
          if t.match(/\[/)
            state = :in_comment
          elsif t.match(/\=/)
            equal_start_amount = equal_start_amount ? equal_start_amount + 1 : 1
            state = :in_open_block_comment
          elsif t.match(/\n/)
            current_token = :comment
            state = :done
          end
        when :in_open_block_comment
          if t.match(/\=/)
            equal_start_amount += equal_start_amount
            state = :in_open_block_comment
          else
            state = :in_close_block_comment
          end
        when :in_close_block_comment
          if t.match(/\=/)
            equal_end_amount = equal_start_amount ? equal_start_amount + 1 : 1
            state = :in_close_block_comment
            last_char = t
          elsif t.match(/\]/) && last_char.match(/\=/)
            if equal_end_amount == equal_start_amount
              current_token = :comment
              state = :done
            else
              current_token = :error
              state = :done
            end
          else
            equal_end_amount = 0
            state = :in_close_block_comment
          end
        when :inid
          if !(t.match(/[_a-zA-Z]/))
            current_token = :id
            state = :done
            save = 0
            unget_next_char
          end
        when :in_square_bracket
          if t.match(/\=/)
            equal_start_amount = equal_start_amount ? equal_start_amount + 1 : 1
            state = :in_open_string
          else
            current_token = :lsb
            state = :done
          end
        when :in_open_string
          if t.match(/\=/)
            equal_start_amount += 1
            state = :in_open_string
          else
            state = :in_close_string
          end
        when :in_close_string
          if t.match(/\=/)
            equal_end_amount = equal_end_amount ? equal_end_amount + 1 : 1
            state = :in_close_string
            last_char = t
          elsif t.match(/\]/) && last_char.match(/\=/)
            if equal_end_amount == equal_start_amount
              current_token = :string
              state = :done
            else
              current_token = :error
              state = :done
            end
          else
            if t.match(/\\/)
              state = :in_escape
            else
              equal_end_amount = 0
              state = :in_close_string
            end
          end
        when :in_escape
          if t.match(/[n|t|r]/)
            current_token = :error
            state = :done
          else
            if t.match(/\=/)
              equal_end_amount = equal_end_amount ? equal_end_amount + 1 : 1
            end
            state = :in_close_string
          end
        when :ineql
          if t.match(/\=/)
            current_token = :comp
          else
            current_token = :eql
          end
          state = :done
          save = 0
        when :indiff
          if t.match(/\=/)
            current_token = :diff
            state = :done
            save = 0
          else
            current_token = :error
            state = :error
          end
        when :inlower_than
          if t.match(/\=/)
            current_token = :let
          else
            current_token = :lt
            unget_next_char
          end
          state = :done
          save = 0
        when :ingreater_than
          if t.match(/\=/)
            current_token = :get
          else
            current_token = :gt
            unget_next_char
          end
          state = :done
          save = 0
        when :indot
          if t.match(/[^\.]/)
            current_token = :dot
            state = :done
            save = 0
            unget_next_char
          else
            state = :in_double_dot
          end
        when :in_double_dot
          if t.match(/[^\.]/)
            current_token = :conc
            unget_next_char
          else
            current_token = :rng
          end
          state = :done
          save = 0
        when :instring
          if t.match(/\'/)
            state = :done
            current_token = :string
          elsif t.match(/\\/)
            get_next_char
          elsif t.match(/\n/)
            current_token = :error
            state = :done
          end
        when :indouble_string
          if t.match(/\"/)
            state = :done
            current_token = :string
          elsif t.match(/\\/)
            get_next_char
          elsif r.match(/\n/)
            current_token = :error
            state = :done
          end
        when :in_not_number
          if t.match(/[\s|\t|\n|\r|\0|]/)
            current_token = :error
            state = :done
            save = 0
          end
        end
        
        if save == 1
          token_string += t
        end
          
        if save == 0 && current_token == :name
          current_token = reserved_word(token_string)
        end
        
        t = get_next_char
      end
      
      return current_token
    end
    
    def get_next_char
      if line
        if line_position >= line.length - 1
          self.line_number = line_number ? line_number + 1 : 1
          self.line = file.gets
          self.line_position = 0
        else
          self.line_position += 1
        end
      end
      
      if line.nil?
        self.eof = true
        :eof
      else
        line[line_position].chr
      end
    end
    
    def unget_next_char
      if !eof
        self.line_position -= 1
      end
    end
end