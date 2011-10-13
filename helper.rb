module Helper
  #TODO This module will be responsible to generate the errors in the application.
  module Error
    
  end

  # Series of helper methods that handles the input/output control of the compiler.
  # Method such as the generation of the scanner output file are generated here.
  module IO
    OUTPUT_FOLDER = "outputs"
    
    def formatted_gets(options = {:as => "string"})
      input = gets.strip
      case options[:as]
      when "int" || "integer" then input = input.to_i
      else input
      end
    end
    
    def output(obj, output_type = :file)
      case obj.class.to_s
      when "Scanner" then output_scan(obj, output_type)
      when "Parser" then "Not implemented yet"
      end
    end

    def output_scan(scan, output_type = :file)
      if output_type.eql?(:file)
        stdout = $stdout
        output_file = File.new(output_file_name(:scan), "w+")
        $stdout = output_file
      end

      file = File.open($file_name, "r+")      
      line_number = 1
      while line = file.gets
        puts_line_number line.strip, line_number, :no_tab => true
        scan.tokens.collect do |token|
          if token.line_number == line_number
            case token.type
            when :reserved_word
              puts_line_number "reserved_word: #{token.value}", line_number
            when token.special_symbol?
              puts_line_number "#{token.value}", line_number 
            when :number
              puts_line_number "NUM, val= #{token.value}", line_number 
            when :string
              puts_line_number "STR, val= \"#{token.value}\"", line_number 
            when :identifier
              puts_line_number "ID, name= #{token.value}", line_number 
            end
          end
        end
        line_number += 1
      end
      
      $stdout = stdout if stdout
    end
    
    def output_file_name(action)
      "#{OUTPUT_FOLDER}/#{timestamp}_#{File.basename($file_name, ".lua")}_#{action}"
    end
    
    def puts_line_number(string, line_number, options = {})
      puts "#{options[:no_tab] ? "" : "\t "}%3d: #{string}" % line_number
    end
    
    def timestamp
      Time.now.strftime("%Y%m%d%H%M%S")
    end
  end
end