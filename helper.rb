module Helper
  module IO
    def formatted_gets options = {:as => "string"}
      input = gets.strip
      case(options[:as])
      when "int" || "integer" then input = input.to_i
      else input
      end
    end
  end
end