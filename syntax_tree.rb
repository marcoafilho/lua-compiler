class SyntaxTree
  attr_accessor :root
  
  class Node
    SCOPE = [:local, :global]
    NODE = [:chunk, :stat, :laststat, :var, :funcname, :funcbody, :table_constructor, :field, :exp, :functioncall, :terminal, :list, :block]
    STAT = [:if, :while, :repeat, :function, :function_call_stat, :assign, :for, :in]
    LAST_STAT = [:return, :break]
    EXP = [:op, :const, :id, :function_exp, :terminal_exp]
    TERMINAL = [:number, :string, :identifier, :nil, :false, :true, :terminal_list]
    LIST = [:namelist, :varlist, :parlist, :explist]

    TYPE = [:error, :unknown, :nil, :number, :boolean, :string, :function, :user_data, :thread, :table]
    
    attr_accessor :children, :parent, :scope, :token, :type
    attr_reader :types
    
    def initialize(attrs = {})
      @children = attrs[:children] ? attrs[:children] : []
      @token = attrs[:token]
      @type = attrs[:type]
      
      self
    end
    
    def add_child(child)
      raise "Erro de alguma coisa" unless child.valid_type?
      child.parent = self

      self.children << child
    end
    
    def add_terminal_child(token)
      child = SyntaxTree::Node.new(:type => :terminal, :token => token)
      add_child(child)
    end
    
    def terminal?
      TERMINAL.include? type
    end
    
    def types
      @types ||= (SCOPE + NODE + STAT + LAST_STAT + EXP + TERMINAL + LIST + TYPE).flatten
    end
    
    def valid_type?
      types.include? type
    end
  end
end