require "helper"
require "scanner"

include Helper::IO

$file = File.open(formatted_gets, "r+")
option = formatted_gets :as => "int"

case(option)
when 1 
  scan = Scanner.new($file).scan
  output(scan, :terminal)
when 2
end