require "helper"
require "scanner"
require "parser"

include Helper::IO

$file_name = formatted_gets
option = formatted_gets :as => "int"

case(option)
when 1
  scan = Scanner.new($file_name).scan
  output(scan)  
  # begin
    parse = Parser.new(scan.tokens).parse
    output(parse)
    puts "PARSER OK"
  # rescue
    puts "PARSER REJECT"
  # end
when 2
  scan = Scanner.new($file_name).scan
  output(scan)
when 3
  scan = Scanner.new($file_name).scan
  begin
    parse = Parser.new(scan.tokens).parse
    output(parse)
    puts "PARSER OK"
  rescue
    puts "PARSER REJECT"
  end
end