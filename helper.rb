module Helper
  module IO
    def formatted_gets(options = {:as => "string"})
      input = gets.strip
      case options[:as]
      when "int" || "integer" then input = input.to_i
      else input
      end
    end
    
    def output(obj, output_type = :file)
      case obj.class.to_s
      when "Scanner" then output_scan(output_type)
      when "Parser" then "Not implemented yet"
      end
    end

    def output_scan(output_type)
      file = $file

      line_number = 1
      while line = file.gets
        puts_line_number line.strip, line_number, :no_tab => true
        scan.tokens.collect do |token|
          if token.line_number == line_number
            case token.type
            when :reserved_word
              puts_line_number "reserved_word: #{token.value}", line_number
            when token.special_symbol?
              puts_line_number "\t %3d: #{token.value}", line_number 
            when :number
              puts_line_number "\t %3d: NUM, val= #{token.value}", line_number 
            when :string
              puts_line_number "\t STR, val= \"#{token.value}\"", line_number 
            when :identifier
              puts_line_number "\t %3d: ID, name= #{token.value}", line_number 
            end
          end
        end
        line_number += 1
      end
    end
    
    def puts_line_number(string, line_number, options = {})
      puts "#{options[:no_tab] "" : "\t "}%3d: #{string}" % line_number
    end
  end
end