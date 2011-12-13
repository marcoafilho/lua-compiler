require "syntax_tree"

class Parser
  class ParserReject < StandardError
    STD_MESSAGE = "PARSER REJECT"
  end
  
  attr_reader :tokens
  attr_accessor :remaining_tokens, :look_ahead, :syntax_tree
  
  def initialize(tokens)
    @tokens = tokens
    @remaining_tokens = tokens
    @syntax_tree = SyntaxTree.new
  end
  
  def parse
    self.look_ahead = next_token
    syntax_tree.root = chunk

    raise_parser_reject unless look_ahead.end_of_file?
    
    syntax_tree
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
    node = SyntaxTree::Node.new(:type => :chunk)
    
    while look_ahead.starter?
      node.add_child(stat)
      optscolon
    end
    if look_ahead.breaker?
      node.add_child(laststat)
    end
    
    node
  end
  
  def block
    chunk
  end
  
  def stat
    node = SyntaxTree::Node.new(:type => :stat)
    
    case look_ahead.parser_type
    when :identifier
      prefix_node = node.add_child(prefixexp).last
      while look_ahead.parser_type == :comma && prefix_node.type == :var
        accept
        node.add_child(prefixexp)
      end
      
      if prefix_node.type == :var
        stat_node = SyntaxTree::Node.new(:type => :assign)
        list_node = SyntaxTree::Node.new(:type => :var_list)
        stat_node.add_child(list_node)
        
        if look_ahead.parser_type == :assign
          accept
          stat_node.add_child(explist)
        end
        node = stat_node
      end
      
      #TODO remove this if application is working
      # accept
      # varlist
      # if look_ahead.parser_type == :assign
      #   accept
      #   explist
      # end
    when :do
      accept
      node = block
      accept(:end)
    when :while
      node.type = :while
      
      accept
      node.add_child(logicexp)
      accept(:do)
      node.add_child(block)
      accept(:end)
    when :repeat
      node.type = :repeat
      
      accept
      node.add_child(block)
      accept(:until)
      node.add_child(logicexp)
    when :if
      node.type = :if
      
      accept
      node.add_child(logicexp)
      accept(:then)
      node.add_child(block)
      
      while look_ahead.parser_type == :elseif
        elsif_node = SyntaxTree::Node(:type => :if)
        accept
        elsif_node.add_child(logicexp)
        accept(:then)
        elsif_node.add_child(block)
        node.add_child(elsif_node)
      end
      
      if look_ahead.parser_type == :else
        accept
        node.add_child(block)
      end
      
      accept(:end)
    when :for
      node.type = :for
      
      accept
      node.add_terminal_child(accept(:identifier))
      if look_ahead.parser_type == :assign
        accept
        node.add_child(logicexp)
        accept(:comma)
        node.add_child(logicexp)
        if look_ahead.parser_type == :comma
          accept
          node.add_child(logicexp)
        end
      else
        stat_node = SyntaxTree::Node.new(:type => :in)
        node.add_child(stat_node)
        node.add_child(namelistexp)
        accept(:in)
        node.add_child(explist)
      end
      
      accept(:do)
      node.add_child(block)
      accept(:end)
    when :function
      node.type = :function
      accept
      node.add_child(funcname)
      node.add_child(funcbody)
    when :local
      accept
      if look_ahead.parser_type == :function
        node.type = :function
        node.add_terminal_child(accept(:identifier))
        node.add_child(funcbody)
      elsif look_ahead.parser_type == :identifier 
        node.type = :assign
        if look_ahead.parser_type == :identifier
          node.add_child(namelist)
        end
        
        if look_ahead.parser_type == :assign
          accept(:assign)
          node.add_child(explist)
        end
      else
        raise_parser_reject
      end
    else
      raise_parser_reject
    end
    
    node
  end
  
  def laststat
    node = SyntaxTree::Node.new(:type => :laststat)
    
    case look_ahead.parser_type
    when :return
      node.type = :return
      accept
      node.add_child(explist)
    when :break
      accept
      node.type = :break
    else
      raise_parser_reject
    end
    
    node
  end
  
  def funcname
    node = SyntaxTree::Node.new(:type => :funcname)
    node.token = look_ahead
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
  
  # def varlist
  #   node = SyntaxTree::Node.new
  #   
  #   while look_ahead.parser_type == :comma
  #     accept
  #     var
  #   end
  #   var  
  #   
  #   node
  # end
  # 
  # def var
  #   prefixexprest    
  # end
    
  def namelistexp;  end
  
  def namelist
    node = SyntaxTree::Node.new(:type => :namelist)
    
    if look_ahead.parser_type == :identifier
      node.add_terminal_child(accept(:identifier))
      node.add_child(namelistexp)
    end
    
    while look_ahead.parser_type == :comma
      accept
      node.add_terminal_child(accept(:identifier))
    end
    
    node
  end
  
  def explist
    node = SyntaxTree::Node.new(:type => :explist)
    
    node.add_child(logicexp)
    while look_ahead.parser_type == :comma
      accept
      node.add_child(logicexp)
    end
  end
  
  # Expressions by priority
  def logicexp
    node = comparisonexp
    
    while look_ahead.parser_type == :or || look_ahead.parser_type == :and
      node.type = :op
      node.token = look_ahead
      accept
      node.add_child(comparisonexp)
    end
    
    node
  end
    
  def comparisonexp
    node = modularexp

    while look_ahead.comparator?
      node.type = :op
      node.token = look_ahead
      accept
      node.add_child(modularexp)
    end
    
    node
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
    node = SyntaxTree::Node.new
    
    if look_ahead.parser_type == :identifier
      node.type = :var
      node.add_terminal_child(look_ahead)
      
      accept
    else
      accept(:open_parentheses)
      node = logicexp
      accept(:close_parentheses)
    end
    
    while 1
      case look_ahead.parser_type
      when :open_sbrackets
        accept
        node.add_child(logicexp)
        accept(:close_sbrackets)
        next
      when :dot
        accept
        node.add_terminal_child(accept(:identifier))
        next
      when :open_parentheses || :open_brackets || :string
        node.type = :functioncall
        node.add_child(args)
        next
      when :concatenation
        accept
        node.type = :functioncall
        node.add_terminal_child(accept(:identifier))
        node.add_child(args)
        next
      end
      break
    end
        
    node
  end
  
  #TODO Check usage to remove this method
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