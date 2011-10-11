class Token
  # attr_accessor :type, :value
  # 
  # def initialize(attrs = {})
  #   @type = attrs[:type]
  #   @value = attrs[:value]    
  # end
  # 
  TOKEN_TYPE = {
    :and => "and", :break => "break", :do => "do", :else => "else", :elseif => "elseif", 
    :end => "end", :false => "false", :for => "for", :function => "function", :if => "if", 
    :in => "in", :local => "local", :nil => "nil", :not => "not", :or => "or", 
    :repeat => "repeat", :return => "return", :then => "then", :true => "true", :until => "until", 
    :while => "while",
    
    :plus => "+", :min => "-", :mult => "*", :div => "\"", :mod => "%", :circ => "^", :hash => "#",
    :comp => "==", :diff => "~=", :let => "<=", :get => ">=", :lt => "<", :gt => ">", :eql => "=", 
    :lp => "(", :rp => ")", :lsb => "[", :rsb => "]", :lb => "{", :rb => "}", 
    :scol => ";", :col => ":", :com => ",", :dot => ".", :ddot => "..", :tdot => "...",
    
    :other => {
      :identifier => "ID", :string => "STR", 
      :number => "NUM", :comment => "COMMENT"      
    }
  }
  
  # TOKEN_TYPE = {
  #   :and, :break, :do, :else, :elseif,
  #   :end, :false, :for, :function, :if,
  #   :in, :local, :nil, :not, :or,
  #   :repeat, :return, :then, :true, :until,
  #   :while,
  #   
  #   :plus, :min, :mult, :div, :mod, :circ, :hash,
  #   :comp, :diff, :let, :get, :lt, :eql,
  #   :lp, :rp, :lsb, :rsb, :lb, :rb,
  #   :scol, :col, :com, :dot, :conc, :rng,
  #   
  #   :id, :string, :number, :comment
  # }
end