module Helper
  #TODO This module will be responsible to generate the errors in the application.
  module Error
    
  end

  # Series of helper methods that handles the input/output control of the compiler.
  # Method such as the generation of the scanner output file are generated here.
  module IO
    OUTPUT_FOLDER = "outputs"
    
    def create_file(file_name, extension = nil)
      stdout = $stdout
      output_file = File.new(output_file_name(file_name, extension), "w+")
      $stdout = output_file
      
      stdout
    end
    
    def rollback_stdout(stdout)
      $stdout = stdout if stdout
    end
    
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
      when "SyntaxTree" then output_parse(obj, output_type)
      end
    end

    def output_scan(scan, output_type = :file)
      stdout = create_file(:scan) if output_type.eql?(:file)

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
      
      rollback_stdout(stdout)
    end
    
    def output_parse(parse, output_type = :file)
      puts output_file_name(:parse, ".xml")
      stdout = create_file(:parse, ".xml") if output_type.eql?(:file)
      
      level = 0
      puts "<root>"
      puts_children(parse.root, level + 1) unless parse.root.children.empty?
      puts "</root>"
      
      rollback_stdout(stdout)
    end
    
    def output_file_name(action, extension = nil)
      "#{OUTPUT_FOLDER}/#{timestamp}_#{File.basename($file_name, ".lua")}_#{action}#{extension}"
    end
    
    def puts_line_number(string, line_number, options = {})
      puts "#{options[:no_tab] ? "" : "\t "}%3d: #{string}" % line_number
    end
    
    def puts_children(node, level)
      tabs = "\t" * level
      node.children.each do |child|
        if child.terminal?
          puts "#{tabs}<#{child.type}>#{child.token.value}</#{child.type}>"
        else
          puts "#{tabs}<#{child.type}>"
          puts_children(child, level + 1) unless child.children.empty?
          puts "#{tabs}</#{child.type}>"
        end
      end
    end
    
    def timestamp
      Time.now.strftime("%Y%m%d%H%M%S")
    end
  end
end