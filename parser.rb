class Parser
  class ParserReject < StandardError
    STD_MESSAGE = "PARSER REJECT"
  end
  
  attr_reader :tokens
  attr_accessor :remaining_tokens, :look_ahead
  
  def initialize(tokens)
    @tokens = tokens
    @remaining_tokens = tokens
  end
  
  def parse
    self.look_ahead = next_token
    chunk

    raise_parser_reject unless look_ahead.end_of_file?
    self
  end
  
  protected

  def raise_parser_reject
    raise ParserReject, ParserReject::STD_MESSAGE
  end
  
  def next_token
    remaining_tokens.shift
  end
  
  def accept(type = nil)
    if !type || look_ahead.parser_type == type
      self.look_ahead = next_token
    else
      raise_parser_reject
    end
  end
  
  private  

  # This is the parser starter.
  # chunk := {{{identifier | open_parentheses | ...} stat} | {{return | break} laststat}} [';']
  def chunk
    while look_ahead.starter? || look_ahead.breaker?
      look_ahead.starter? ? stat : laststat
      optscolon
    end
  end
  
  def block
    chunk
  end
  
  def stat
    case look_ahead.parser_type
    when :identifier
      accept
      varlist
      if look_ahead.parser_type == :assign
        accept
        explist
      end
    when :do
      accept
      block
      accept(:end)
    when :while
      accept
      logicexp
      accept(:do)
      block
      accept(:end)
    when :repeat
      accept
      block
      accept(:until)
      logicexp
    when :if
      accept
      logicexp
      accept(:then)
      block
      
      while look_ahead.parser_type == :elseif
        accept
        logicexp
        accept(:then)
        block
      end
      
      if look_ahead.parser_type == :else
        accept
        block
      end
      
      accept(:end)
    when :for
      accept
      accept(:identifier)
      if look_ahead.parser_type == :assign
        accept
        logicexp
        accept(:comma)
        logicexp
        if look_ahead.parser_type == :comma
          accept
          logicexp
        end
      else
        namelistexp
        accept(:in)
        explist
      end
      
      accept(:do)
      block
      accept(:end)
    when :function
      accept
      funcname
      funcbody
    when :local
      accept
      if look_ahead.parser_type == :function
        accept(:identifier)
        funcbody
      elsif look_ahead.parser_type == :identifier
        accept
        while look_ahead.parser_type == :comma
          accept
          accept(:identifier)
        end
        
        if look_ahead.parser_type == :assign
          accept(:assign)
          explist
        end
      else
        raise_parser_reject
      end
    else
      raise_parser_reject
    end
  end
  
  def laststat
    case look_ahead.parser_type
    when :return
      accept
      explist
    when :break
      accept
    else
      raise_parser_reject
    end
  end
  
  def funcname
    accept(:identifier)

    while look_ahead.parser_type == :comma
      accept
      accept(:identifier)
    end
    
    if look_ahead.parser_type == :concatenation
      accept
      accept(:identifier)
    end
  end
  
  def varlist
    while look_ahead.parser_type == :comma
      accept
      var
    end
    var  
  end

  def var
    prefixexprest    
  end
    
  def namelistexp; end
  
  def namelist
    while look_ahead.parser_type == :comma
      accept
      accept(:identifier)
    end    
  end
  
  def explist
    logicexp
    while look_ahead.parser_type == :comma
      accept
      logicexp
    end
  end
  
  # Expressions by priority
  def logicexp
    comparisonexp
    while look_ahead.parser_type == :or || look_ahead.parser_type == :and
      accept
      comparisonexp
    end
  end
    
  def comparisonexp
    modularexp
    while look_ahead.comparator?
      accept
      modularexp
    end
  end
  
  def modularexp
    arithmeticexp
    while look_ahead.parser_type == :multiplication || look_ahead.parser_type == :division || 
          look_ahead.parser_type == :module || look_ahead.parser_type == :exponentiation
      accept
      arithmeticexp
    end
  end
  
  def arithmeticexp
    unaryexp
    while look_ahead.parser_type == :addition || look_ahead.parser_type == :subtraction
      accept
      unaryexp 
    end
  end
  
  def unaryexp    
    finalexp
    while look_ahead.parser_type == :not || look_ahead.parser_type == :hashtag
      accept
      finalexp
    end
  end
  
  def finalexp
    case look_ahead.parser_type
    when :nil then accept
    when :false then accept
    when :number then accept
    when :string then accept
    when :list then accept
    when :function then accept
    when :identifier || :open_parentheses then prefixexp
    when :minus || :not || :hashtag
      accept
      logicexp
    when :open_brackets then tableconstructor
    else raise_parser_reject
    end
  end
    
  def prefixexp
    if look_ahead.parser_type == :identifier
      accept
      prefixexprest
    else
      accept(:open_parentheses)
      logicexp
      accept(:close_parentheses)
      prefixexprest
    end
  end
  
  def prefixexprest
    while 1
      case look_ahead.parser_type
      when :open_sbrackets
        accept
        logicexp
        accept(:close_sbrackets)
        next
      when :dot
        accept
        accept(:identifier)
        next
      when :open_parentheses || :open_brackets || :string
        args
        next
      when :concatenation
        accept
        accept(:identifier)
        args
        next
      end
      break
    end
  end
  
  def functioncall; end
  
  def args
    if look_ahead.parser_type == :open_parentheses
      accept
      if look_ahead.parser_type == :close_parentheses
        accept
      else
        explist
        accept(:close_parentheses)
      end
    else
      if look_ahead.parser_type == :open_brackets
        tableconstructor
      else
        if look_ahead.parser_type == :string
          accept
        else
          raise_parser_reject
        end 
      end
    end
  end
  
  def function
    accept(:function)
    funcbody
  end
  
  def funcbody
    accept(:open_parentheses)
    if look_ahead.parser_type == :identifier
      parlist
    end
    accept(:close_parentheses)
    block
    accept(:end)
  end
  
  def parlist
    if look_ahead.parser_type == :identifier
      accept(:identifier)
      namelist
      if look_ahead.parser_type == :comma
        accept
        accept(:list)
      end
    end
  end
  
  def tableconstructor
    accept(:open_brackets)
    fieldlist
    accept(:close_brackets)
  end
    
  def fieldlist
    field
    while look_ahead.parser_type == :comma || look_ahead.parser_type == :semi_colon
      accept
      (look_ahead != :close_sbrackets) ? field : break
    end
  end
  
  def field
    if look_ahead.parser_type == :open_sbrackets
      accept
      logicexp
      accept(:close_sbrackets)
    else
      if look_ahead.parser_type == :identifier
        accept
        accept(:assign)
      end
    end
    
    logicexp unless look_ahead.parser_type == :close_brackets
  end
  
  def fieldsep;end
  
  def binop;end
  
  def unop;end
  
  def optscolon
    accept(:semi_colon) if look_ahead.parser_type == :semi_colon
  end
end