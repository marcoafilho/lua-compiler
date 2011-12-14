Compilador Lua
==============

Para executar a aplicação, basta executar:

	$ ruby main.rb
	
A entrada é feita na seguinte forma:

<caminho do arquivo> 
<opcao>
	
onde,

o caminho do arquivo pode ser absoluto ou relativo;
a opcao pode ser 1,2,3

a opção 1 executa o parser e o scanner sequencialmente e gera ambas as saídas
a opção 2 executa apenas o scanner
a opção 3 executa o parser e o scanner sequencialmente e gera apenas a saída do parser.

* Novo
------

As saídas são sempre geradas numa pasta outputs. Agora está também sendo gerada a árvore sintática. A árvore sintática é um arquivo xml resultante do parser, ou seja, apenas a opção 1 e 3 geram o xml.