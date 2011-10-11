require "helper"
require "scanner"

include Helper::IO

file_name = formatted_gets
option = formatted_gets :as => "int"

@symbol_table = []

case(option)
when 1 then Scanner.new(file_name)
end