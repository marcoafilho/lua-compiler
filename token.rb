class Token
  TOKEN_TYPE = {
    :reserved_words => {
      :and => "and", :break => "break", :do => "do", :else => "else", :elseif => "elseif", 
      :end => "end", :false => "false", :for => "for", :function => "function", :if => "if", 
      :in => "in", :local => "local", :nil => "nil", :not => "not", :or => "or", 
      :repeat => "repeat", :return => "return", :then => "then", :true => "true", :until => "until", 
      :while => "while" 
    },
    :special_symbols => {
      :addition => "+", :subtraction => "-", :multiplication => "*", :division => "\"", 
      :module => "%", :exponentiation => "^", :hashtag => "#", :comparison => "==", 
      :difference => "~=", :lower_equal_than => "<=", :greather_equal_than => ">=", 
      :lower_than => "<", :greater_than => ">", :assign => "=", :open_parentheses => "(",
      :close_parentheses => ")", :open_sbrackets => "[", :close_sbrackets => "]", 
      :open_brackets => "{", :close_brackets => "}", :semi_colon => ";", :colon => ":", 
      :comma => ",", :dot => ".", :concatenation => "..", :list => "..." 
    },
    
    :other => {
      :identifier => "ID", :string => "STR", 
      :number => "NUM", :comment => "COMMENT"      
    }
  }
  
  attr_accessor :line_number, :type, :value
  
  def initialize(attrs = {})
    @line_number = attrs[:line_number]
    @type        = attrs[:type]
    @value       = attrs[:value]
  end
  
  def update_attributes(attrs = {})
    @line_number = attrs[:line_number] if attrs[:line_number]
    @type        = attrs[:type] if attrs[:type]
    @value       = attrs[:value] if attrs[:value]
  end
  
  def update_if(option)
    case option
    when :reserved_word
      if value && word = TOKEN_TYPE[:reserved_words][value.to_sym]
        update_attributes(:type => :reserved_word, :value => word)
      end
    when :special_symbol
      if symbol = TOKEN_TYPE[:special_symbols][type]
        update_attributes(:value => symbol) 
      end
    end
  end
  
  def special_symbol?
    type if Token::TOKEN_TYPE[:special_symbols][type]
  end
end