require "helper"
require "scanner"

include Helper::IO

file_name = formatted_gets
option = formatted_gets :as => "int"

@symbol_table = []

case(option)
when 1 
  scan = Scanner.new(file_name)
  file = File.open(file_name)
  line_number = 1
  while line = file.gets
    puts " %3d: #{line.strip}" % line_number
    scan.tokens.collect do |token| 
      if token.line_number == line_number
        case token.type
        when :reserved_word
          puts "\t %3d: reserved_word: #{token.value}" % token.line_number
        when token.special_symbol?
          puts "\t %3d: #{token.value}" % token.line_number 
        when :number
          puts "\t %3d: NUM, val= #{token.value}" % token.line_number 
        when :string
          puts "\t %3d: STR, val= \"#{token.value}\"" % token.line_number 
        when :identifier
          puts "\t %3d: ID, name= #{token.value}" % token.line_number 
        end
      end
    end
    line_number += 1
  end
end