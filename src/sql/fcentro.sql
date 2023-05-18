# VPM (2022-06-09) - nesta versao temos todos os elementos de topicos (presente na arvore da tabela nested_tipos_secoes) no mesmo nivel hierarquico
# VPM (2022-06-19) - criado versionamento atraves da tabela versoes.
# VPM (2022-06-19) - tentativa de pegar id_chave da tabela secoes nos stored procedures mostra_arvore_niveis_pais_seleciona_tipo*
# VPM (2022-06-19) - tentativa de obter campo trecho e nome_versao da tabela versoes.
# VPM (2022-06-22) - criando forma de ver o documento inteiro, no mesmo visualizador de niveis pela criacao da stored procedure mostra_documento_completo
# VPM (2022-06-28) - preparacao para criar um sistema de mudanca de subarvore dentro da arvore
# VPM (2022-06-29) - criacao das funcoes de insercao de novos nós, antes e depois do atual
# VPM (2022-07-02) - criacao de procedure para gravar trecho quando insere novo filho insere_a_direita_dos_filhos_com_trecho
# VPM (2022-07-10) - cria procedure que faz mostra_documento_completo mostrar niveis para geracao de Latex -> mostra_documento_completo_niveis
# VPM (2022-07-27) - criei trigger para preencher tabela ids_de_referencia com os identificadores das referencias, que precisam ser inteligíveis a partir do que o usuário entra no espaço entre dois [].
# VPM (2022-08-05) - criei mostra_documento_completo_com_pai para permitir a gravacao da tese em formato sql. Eu preciso do nome do pai para poder criar os calls que vão gerar o script SQL. Decidi gravar num script ao invés de usar o dump do mysql
# VPM (2022-08-06) - coloquei item_de_referencia como filho de topico no nested_tipos_secoes, para permitir visualizar tópicos e referencias ao mesmo tempo


DELIMITER //
DROP PROCEDURE IF EXISTS retorna_valores_de_propriedades_do_tipo_secao
//
CREATE PROCEDURE retorna_valores_de_propriedades_do_tipo_secao(IN tipo_secao varchar(200))
BEGIN
select nome_propriedade, nome_valor_discreto, nome_nested_tipo_secao from instancias_propriedades as A, propriedades, valores_discretos, nested_tipos_secoes where A.id_propriedade = id_chave_propriedade and id_valor_discreto=id_chave_valor_discreto and id_nested_tipo_secao = id_chave_nested_tipo_secao and nome_nested_tipo_secao = tipo_secao order by nome_nested_tipo_secao ;
END
//
DROP PROCEDURE IF EXISTS mostra_trilha_da_arvore_descricao_concatenada
//
# a procedure abaixo estaria com problemas? coloca o nivel 2 por ultimo. Ainda bem que eu nao uso
CREATE PROCEDURE mostra_trilha_da_arvore_descricao_concatenada(IN no_de_busca varchar(20))
BEGIN
	SELECT group_concat(T.nomcat SEPARATOR "-") from (
	SELECT parent.descricao as nomcat 
	FROM secoes AS node,
	        secoes AS parent
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	        AND node.nome_categoria = no_de_busca
	ORDER BY parent.lft) as T;
END
//
DROP PROCEDURE IF EXISTS mostra_trilha_da_arvore_codigo_concatenado
//
# a procedure abaixo estaria com problemas? coloca o nivel 2 por ultimo. Ainda bem que eu nao uso
CREATE PROCEDURE mostra_trilha_da_arvore_codigo_concatenado(IN no_de_busca varchar(20))
BEGIN
	SELECT group_concat(T.nomcat SEPARATOR "-") from (
	SELECT parent.nome_categoria as nomcat
	FROM secoes AS node,
	        secoes AS parent
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	        AND node.nome_categoria = no_de_busca
	ORDER BY parent.lft) as T;
END
//
# este estah funcionando.
DROP PROCEDURE IF EXISTS mostra_trilha_da_arvore
//
CREATE PROCEDURE mostra_trilha_da_arvore(IN no_de_busca varchar(100))
BEGIN
	SELECT parent.nome_categoria
	FROM secoes AS node,
	        secoes AS parent
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	        AND node.nome_categoria = no_de_busca
	ORDER BY parent.lft;
END
//
DROP PROCEDURE IF EXISTS retorna_filho_a_direita_tipos_secoes
//
CREATE PROCEDURE retorna_filho_a_direita_tipos_secoes(IN nome_no_pai varchar(100), OUT saida_no varchar(100))
busca:BEGIN

	SELECT @numero:=count(*) from nested_tipos_secoes where nome_nested_tipo_secao = nome_no_pai;

	IF @numero = 0 THEN
		SET saida_no = '';
		LEAVE busca;		
	END iF;

	SELECT @no_filho_encontrado:=node.nome_nested_tipo_secao, (COUNT(parent.nome_nested_tipo_secao) - (MAX(sub_tree.depth) + 1)) AS depth
	FROM nested_tipos_secoes AS node,
	        nested_tipos_secoes AS parent,
	        nested_tipos_secoes AS sub_parent,
	        (
	                SELECT node.nome_nested_tipo_secao, (COUNT(parent.nome_nested_tipo_secao) - 1) AS depth
	                FROM nested_tipos_secoes AS node,
	                        nested_tipos_secoes AS parent
	                WHERE node.lft BETWEEN parent.lft AND parent.rgt
	                        AND node.nome_nested_tipo_secao = nome_no_pai
	                GROUP BY node.nome_nested_tipo_secao
	                ORDER BY MAX(node.lft)
	        )AS sub_tree
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	        AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt
	        AND sub_parent.nome_nested_tipo_secao = sub_tree.nome_nested_tipo_secao
	GROUP BY node.nome_nested_tipo_secao
	HAVING depth = 1
	ORDER BY MAX(node.lft) DESC LIMIT 1;
	#SELECT concat("INterno ", @no_filho_encontrado);
	SET saida_no = @no_filho_encontrado;
	SELECT saida_no;
END
//
DROP PROCEDURE IF EXISTS retorna_filho_a_direita
//
CREATE PROCEDURE retorna_filho_a_direita(IN nome_no_pai varchar(100), OUT saida_no varchar(100))
busca:BEGIN

	SELECT @numero:=count(*) from secoes where nome_categoria = nome_no_pai;

	IF @numero = 0 THEN
		SET saida_no = '';
		LEAVE busca;		
	END iF;

	SELECT @no_filho_encontrado:=node.nome_categoria, (COUNT(parent.nome_categoria) - (MAX(sub_tree.depth) + 1)) AS depth
	FROM secoes AS node,
	        secoes AS parent,
	        secoes AS sub_parent,
	        (
	                SELECT node.nome_categoria, (COUNT(parent.nome_categoria) - 1) AS depth
	                FROM secoes AS node,
	                        secoes AS parent
	                WHERE node.lft BETWEEN parent.lft AND parent.rgt
	                        AND node.nome_categoria = nome_no_pai
	                GROUP BY node.nome_categoria
	                ORDER BY MAX(node.lft)
	        )AS sub_tree
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	        AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt
	        AND sub_parent.nome_categoria = sub_tree.nome_categoria
	GROUP BY node.nome_categoria
	HAVING depth = 1
	ORDER BY MAX(node.lft) DESC LIMIT 1;
	#SELECT concat("INterno ", @no_filho_encontrado);
	SET saida_no = @no_filho_encontrado;
	SELECT saida_no;
END
//
DROP PROCEDURE IF EXISTS insere_a_direita_dos_filhos_tipos_secoes
//
CREATE PROCEDURE insere_a_direita_dos_filhos_tipos_secoes(IN nome_no_pai varchar(200), IN no_para_inserir varchar(200), IN no_descricao varchar(10000))
funcao:BEGIN

	CALL retorna_filho_a_direita_tipos_secoes(nome_no_pai, @no_filho_a_direita);
	#SELECT concat("Retornou da chamada: ", @no_filho_a_direita);
	IF @no_filho_a_direita = '' THEN
		SELECT "Não foi possível encontrar o no!";
		LEAVE funcao;
	END IF;

	IF @no_filho_a_direita = nome_no_pai THEN
		#SELECT "Insere abaixo";
		SELECT @myLeft := lft FROM nested_tipos_secoes
		
		WHERE nome_nested_tipo_secao = nome_no_pai;
		
		UPDATE nested_tipos_secoes SET rgt = rgt + 2 WHERE rgt > @myLeft;
		UPDATE nested_tipos_secoes SET lft = lft + 2 WHERE lft > @myLeft;
		
		INSERT INTO nested_tipos_secoes(nome_nested_tipo_secao, descricao, lft, rgt) VALUES(no_para_inserir, no_descricao,   @myLeft + 1, @myLeft + 2);
	ELSE
		#SELECT concat("Insere do lado - pai: ",nome_no_pai," a inserir ",no_para_inserir, "retorno da funcao ", @no_filho_a_direita); 
		#SELECT concat("O filho a direita é: ", @no_filho_a_direita);
		
		SELECT @myRight := rgt FROM nested_tipos_secoes
		WHERE nome_nested_tipo_secao = @no_filho_a_direita;
		
		UPDATE nested_tipos_secoes SET rgt = rgt + 2 WHERE rgt > @myRight;
		UPDATE nested_tipos_secoes SET lft = lft + 2 WHERE lft > @myRight;
		
		INSERT INTO nested_tipos_secoes(nome_nested_tipo_secao, descricao,  lft, rgt) VALUES(no_para_inserir, no_descricao,  @myRight + 1, @myRight + 2);
	END IF;

END
//
DROP PROCEDURE IF EXISTS insere_a_direita_dos_filhos
//
CREATE PROCEDURE insere_a_direita_dos_filhos(IN nome_no_pai varchar(100), IN no_para_inserir varchar(100), IN no_descricao varchar(10000), IN no_link varchar(300), IN tipo_secao int)
funcao:BEGIN

	CALL retorna_filho_a_direita(nome_no_pai, @no_filho_a_direita);
	#SELECT concat("Retornou da chamada: ", @no_filho_a_direita);
	IF @no_filho_a_direita = '' THEN
		SELECT "Não foi possível encontrar o no!";
		LEAVE funcao;
	END IF;

	IF @no_filho_a_direita = nome_no_pai THEN
		#SELECT "Insere abaixo";
		SELECT @myLeft := lft FROM secoes
		
		WHERE nome_categoria = nome_no_pai;
		
		UPDATE secoes SET rgt = rgt + 2 WHERE rgt > @myLeft;
		UPDATE secoes SET lft = lft + 2 WHERE lft > @myLeft;
		
		INSERT INTO secoes(nome_categoria, descricao, lnk, lft, rgt, id_tipo_secao) VALUES(no_para_inserir, no_descricao, no_link,  @myLeft + 1, @myLeft + 2, tipo_secao);
	ELSE
		#SELECT concat("Insere do lado - pai: ",nome_no_pai," a inserir ",no_para_inserir, "retorno da funcao ", @no_filho_a_direita); 
		#SELECT concat("O filho a direita é: ", @no_filho_a_direita);
		
		SELECT @myRight := rgt FROM secoes
		WHERE nome_categoria = @no_filho_a_direita;
		
		UPDATE secoes SET rgt = rgt + 2 WHERE rgt > @myRight;
		UPDATE secoes SET lft = lft + 2 WHERE lft > @myRight;
		
		INSERT INTO secoes(nome_categoria, descricao, lnk, lft, rgt, id_tipo_secao) VALUES(no_para_inserir, no_descricao, no_link, @myRight + 1, @myRight + 2, tipo_secao);
	END IF;

END
//
# insere antes (a esquerda) do no atual
DROP PROCEDURE IF EXISTS insere_abaixo_do_atual
//
CREATE PROCEDURE insere_abaixo_do_atual(IN nome_no_pai VARCHAR(100), IN nome_do_tipo_de_secao VARCHAR(200), IN in_trecho VARCHAR(3500))
funcao:BEGIN
	call insere_a_direita_dos_filhos(nome_no_pai, CONCAT("auto_",REPLACE(CURRENT_TIMESTAMP(6), ' ', '_')), in_trecho,'', (select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = nome_do_tipo_de_secao));
	INSERT INTO versoes(id_secao, trecho) VALUES (LAST_INSERT_ID(), in_trecho);
END
//
# insere antes (a esquerda) do no atual
DROP PROCEDURE IF EXISTS insere_a_esquerda_do_atual
//
CREATE PROCEDURE insere_a_esquerda_do_atual(IN nome_no VARCHAR(100), IN id_do_tipo_de_secao INT, IN in_descricao VARCHAR(3500))
funcao:BEGIN
	SELECT @tmp_esq:= lft from secoes where nome_categoria = nome_no;
	SELECT @time_stampa :=  CURRENT_TIMESTAMP(3);
	SELECT @time_stampa_short :=  CURRENT_TIMESTAMP;
	
	#cria novo espaco
	UPDATE secoes set lft = lft + 2 where lft >= @tmp_esq;
	UPDATE secoes set rgt = rgt + 2 where rgt >= @tmp_esq;
	#cria novo no
 	INSERT INTO secoes(nome_categoria, descricao, lnk, lft, rgt, id_tipo_secao) VALUES(CONCAT("auto_", REPLACE(@time_stampa, " ", "_")), in_descricao, "",  @tmp_esq, @tmp_esq + 1, id_do_tipo_de_secao);
	INSERT INTO versoes(id_secao, trecho) VALUES (LAST_INSERT_ID(), in_descricao);

END
//
# insere depois (a direita) do no atual
DROP PROCEDURE IF EXISTS insere_a_direita_do_atual
//
CREATE PROCEDURE insere_a_direita_do_atual(IN nome_no VARCHAR(100), IN id_do_tipo_de_secao INT, IN in_descricao VARCHAR(3500))
funcao:BEGIN
	SELECT @tmp_dir:= rgt from secoes where nome_categoria = nome_no;
	SELECT @time_stampa :=  CURRENT_TIMESTAMP(3);
	SELECT @time_stampa_short :=  CURRENT_TIMESTAMP;
	
	#cria novo espaco
	UPDATE secoes set lft = lft + 2 where lft > @tmp_dir;
	UPDATE secoes set rgt = rgt + 2 where rgt > @tmp_dir;
	#cria novo no
 	INSERT INTO secoes(nome_categoria, descricao, lnk, lft, rgt, id_tipo_secao) VALUES(CONCAT("auto_", REPLACE(@time_stampa," ","_")), in_descricao, "",  @tmp_dir + 1, @tmp_dir + 2, id_do_tipo_de_secao);
	INSERT INTO versoes(id_secao, trecho) VALUES (LAST_INSERT_ID(), in_descricao);

END
//
DROP PROCEDURE IF EXISTS transpoe_subarvore
//
CREATE PROCEDURE transpoe_subarvore(IN nome_no_para_transpor varchar(100), IN nome_no_onde_inserir varchar(100))
funcao:BEGIN
	SELECT @tmp_esq:= lft from secoes where nome_categoria = nome_no_para_transpor;
	SELECT @tmp_dir:= rgt from secoes where nome_categoria = nome_no_para_transpor;
 
	SELECT @largura_do_no:=rgt - lft + 1 from secoes where nome_categoria = nome_no_para_transpor;
	
	SELECT @esq_da_insercao:=lft from secoes where nome_categoria = nome_no_onde_inserir;

	SELECT @distancia_para_insercao:=lft - @tmp_esq + 1 from secoes where nome_categoria = nome_no_onde_inserir; 

	#cria novo espaco
	UPDATE secoes set lft = lft + @largura_do_no where lft > @esq_da_insercao;
	UPDATE secoes set rgt = rgt + @largura_do_no where rgt > @esq_da_insercao;
	#move subtree
	UPDATE secoes set lft = lft + @distancia_para_insercao, rgt = rgt + @distancia_para_insercao where lft >= @tmp_esq AND rgt <= @tmp_dir;
	#apaga espaco da subtree original
        UPDATE secoes set lft = lft - @largura_do_no where lft > @tmp_dir;
	UPDATE secoes set rgt = rgt - @largura_do_no where rgt > @tmp_dir; 

END
//
DROP PROCEDURE IF EXISTS mostra_arvore_tipos_secoes
//
CREATE PROCEDURE mostra_arvore_tipos_secoes()
BEGIN
	SELECT CONCAT( REPEAT('   ', COUNT(parent.nome_nested_tipo_secao) - 1), node.nome_nested_tipo_secao) AS nome_tipo_secao
	FROM nested_tipos_secoes AS node,
	        nested_tipos_secoes AS parent
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	GROUP BY node.nome_nested_tipo_secao
	ORDER BY MAX(node.lft);
END
//
DROP PROCEDURE IF EXISTS mostra_arvore_abaixo_secao
//
CREATE PROCEDURE mostra_arvore_abaixo_secao(IN in_nome_secao VARCHAR(100))
BEGIN
	DECLARE esq INT DEFAULT 0;
	DECLARE dir INT DEFAULT 0;
	SET esq = (SELECT lft from secoes where nome_categoria = in_nome_secao);
	SET dir = (SELECT rgt from secoes where nome_categoria = in_nome_secao);
	DELETE FROM guarda_ids_da_lixeira;
 	INSERT INTO guarda_ids_da_lixeira (id_da_secao_da_lixeira) SELECT node.id_chave_categoria AS id_secao
	FROM secoes AS node,
	        secoes AS parent
	WHERE node.lft BETWEEN parent.lft AND parent.rgt AND 
		  node.lft >= esq AND node.rgt <= dir
	GROUP BY node.nome_categoria
	ORDER BY MAX(node.lft);
END
//
DROP PROCEDURE IF EXISTS mostra_arvore
//
CREATE PROCEDURE mostra_arvore()
BEGIN
	SELECT CONCAT( REPEAT('   ', COUNT(parent.nome_categoria) - 1), node.nome_categoria) AS nome_secao
	FROM secoes AS node,
	        secoes AS parent
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	GROUP BY node.nome_categoria
	ORDER BY MAX(node.lft);
END
//
DROP PROCEDURE IF EXISTS mostra_arvore_niveis_tipos_secoes_com_pai
//
CREATE PROCEDURE mostra_arvore_niveis_tipos_secoes_com_pai()
BEGIN
	SELECT 
		COUNT(parent.nome_nested_tipo_secao) - 1 as nivel, 
		@nome:=node.nome_nested_tipo_secao AS nome_secao_tipo_secao, 
		node.id_chave_nested_tipo_secao as id_tipo_secao,
		(
			select 
				nome_nested_tipo_secao 
			from 
				nested_tipos_secoes 
			where 
				lft < (select lft from nested_tipos_secoes where nome_nested_tipo_secao=@nome) and rgt > (select rgt from nested_tipos_secoes where nome_nested_tipo_secao=@nome) 
			order by lft DESC limit 1
		) as pai 
	FROM 
		nested_tipos_secoes AS node, nested_tipos_secoes AS parent  
	WHERE 
		node.lft BETWEEN parent.lft AND parent.rgt 
	GROUP BY 
		node.nome_nested_tipo_secao, node.id_chave_nested_tipo_secao 
	ORDER BY MAX(node.lft);
END
//
DROP PROCEDURE IF EXISTS mostra_arvore_niveis_tipos_secoes
//
CREATE PROCEDURE mostra_arvore_niveis_tipos_secoes()
BEGIN
	SELECT COUNT(parent.nome_nested_tipo_secao) - 1 as nivel, node.nome_nested_tipo_secao AS nome_secao_tipo_secao, node.id_chave_nested_tipo_secao as id_tipo_secao
	FROM nested_tipos_secoes AS node,
	        nested_tipos_secoes AS parent
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	GROUP BY node.nome_nested_tipo_secao, node.id_chave_nested_tipo_secao
	ORDER BY MAX(node.lft);
END
//
DROP PROCEDURE IF EXISTS mostra_arvore_niveis
//
CREATE PROCEDURE mostra_arvore_niveis()
BEGIN
	SELECT COUNT(parent.nome_categoria) - 1 as nivel, node.nome_categoria AS nome_secao
	FROM secoes AS node,
	        secoes AS parent
	WHERE node.lft BETWEEN parent.lft AND parent.rgt
	GROUP BY node.nome_categoria
	ORDER BY MAX(node.lft);
END
//
DROP PROCEDURE IF EXISTS mostra_arvore_niveis_pais
//
CREATE PROCEDURE mostra_arvore_niveis_pais()
BEGIN
	SELECT 
		T_filho.niveis as nivel, T_filho.filho as id_filho, T_pai.filho as id_pai, (SELECT descricao from secoes where nome_categoria = T_filho.filho) as titulo 
	from 
		(
			SELECT 
				ST.niveis as niveis, ST.filho as filho, ST.esquerda, ST.direita 
			from 
				(
					SELECT 
						COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
					from 
						(
							SELECT 
								node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
							from 
								secoes as node, secoes as parent 
									where node.lft BETWEEN parent.lft AND parent.rgt
						) as T group by T.filho, T.esquerda, T.direita
				) as ST
		) as T_filho 
			left join 
				(
					SELECT 
						ST2.niveis as niveis, ST2.filho as filho, ST2.esquerda, ST2.direita 
					from 
						(
							SELECT 
								COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
							from 
								(
									SELECT 
										node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
									from 
										secoes as node, secoes as parent 
											where node.lft BETWEEN parent.lft AND parent.rgt
								) as T group by T.filho, T.esquerda, T.direita
						) as ST2
				) as T_pai 
					on T_filho.niveis - T_pai.niveis <2 
						where (T_filho.niveis - T_pai.niveis > 0 AND T_filho.esquerda BETWEEN T_pai.esquerda AND T_pai.direita) OR (T_filho.niveis=0 AND T_filho.filho = T_pai.filho) ORDER BY T_filho.esquerda;
END
//
# cria funcao para mostrar todos os niveis como se fossem nivel 1, para mostrar o documento integral
DROP PROCEDURE IF EXISTS mostra_arvore_niveis_pais_seleciona_tipo
//
CREATE PROCEDURE mostra_arvore_niveis_pais_seleciona_tipo(IN tipo_secao varchar(200))
BEGIN

SELECT POS_FINAL.nivel, POS_FINAL.id_chave_filho, POS_FINAL.id_filho, POS_FINAL.id_pai, POS_FINAL.titulo, POS_FINAL.id_nested_tipo_secao, POS_FINAL.nome_nested_tipo_secao, POS_FINAL.esq, POS_FINAL.dir, POS_FINAL.tem_filho, (SELECT trecho from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as ultima_versao,(SELECT nome_versao from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as data, (SELECT count(*) from versoes where id_secao = POS_FINAL.id_chave_filho) as conta_versoes     FROM
(
SELECT FINAL.nivel, FINAL.id_chave_filho, FINAL.id_filho, FINAL.id_pai, FINAL.titulo, FINAL.idtiposecao as id_nested_tipo_secao, (select nome_nested_tipo_secao from nested_tipos_secoes where id_chave_nested_tipo_secao = id_nested_tipo_secao) as nome_nested_tipo_secao, FINAL.tfilho_esquerda as esq, FINAL.tfilho_direita as dir, CASE WHEN (FINAL.tfilho_direita - FINAL.tfilho_esquerda = 1) THEN "NAO_TEM_FILHO" ELSE "TEM_FILHO" END as tem_filho   FROM
(
	SELECT 
		T_filho.niveis as nivel, T_filho.id_chave_filho as id_chave_filho, T_filho.filho as id_filho, T_pai.filho as id_pai, (SELECT descricao from secoes where nome_categoria = T_filho.filho) as titulo, T_filho.id____tipo____secao as idtiposecao, T_filho.tfilhoesquerda as tfilho_esquerda, T_filho.tfilhodireita as tfilho_direita
	from 
		(
			SELECT 
				ST.niveis as niveis, ST.id_chave_filho as id_chave_filho, ST.filho as filho, ST.esquerda as tfilhoesquerda, ST.direita as tfilhodireita, ST.id___tipo___secao as id____tipo____secao 
			from 
				(
					SELECT 
						COUNT(T.pai) - 1 as niveis, T.id_chave_filho as id_chave_filho, T.filho as filho, T.esquerda as esquerda, T.direita as direita, T.id__tipo__secao as id___tipo___secao
					from 
						(
							SELECT 
								node.id_chave_categoria as id_chave_filho, node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita, node.id_tipo_secao as id__tipo__secao 
							from 
								secoes as node, secoes as parent 
									where node.lft BETWEEN parent.lft AND parent.rgt 
						) as T group by T.id_chave_filho, T.filho, T.esquerda, T.direita
				) as ST
		) as T_filho 
			left join 
				(
					SELECT 
						ST2.niveis as niveis, ST2.filho as filho, ST2.esquerda, ST2.direita 
					from 
						(
							SELECT 
								COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
							from 
								(
									SELECT 
										node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
									from 
										secoes as node, secoes as parent 
											where node.lft BETWEEN parent.lft AND parent.rgt 

 
								) as T group by T.filho, T.esquerda, T.direita
						) as ST2
				) as T_pai 
					on T_filho.niveis - T_pai.niveis <2 
						where (T_filho.niveis - T_pai.niveis > 0 AND T_filho.tfilhoesquerda BETWEEN T_pai.esquerda AND T_pai.direita) OR (T_filho.niveis=0 AND T_filho.filho = T_pai.filho) ORDER BY T_filho.tfilhoesquerda) AS FINAL WHERE FINAL.idtiposecao IN 
(
SELECT parent.id_chave_nested_tipo_secao
FROM nested_tipos_secoes AS node,
        nested_tipos_secoes AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rgt
        AND node.nome_nested_tipo_secao = tipo_secao
ORDER BY parent.lft

) ORDER BY FINAL.tfilho_esquerda) AS POS_FINAL order by POS_FINAL.esq;
END
//
DROP PROCEDURE IF EXISTS mostra_arvore_niveis_pais_seleciona_tipos_com_filhos
//
CREATE PROCEDURE mostra_arvore_niveis_pais_seleciona_tipos_com_filhos(IN tipo_secao varchar(200))
BEGIN
SELECT FINAL.nivel, FINAL.id_filho, FINAL.id_pai, FINAL.titulo, FINAL.idtiposecao as id_nested_tipo_secao, (select nome_nested_tipo_secao from nested_tipos_secoes where id_chave_nested_tipo_secao = id_nested_tipo_secao) as nome_nested_tipo_secao, FINAL.tfilho_esquerda FROM
(
	SELECT 
		T_filho.niveis as nivel, T_filho.filho as id_filho, T_pai.filho as id_pai, (SELECT descricao from secoes where nome_categoria = T_filho.filho) as titulo, T_filho.id____tipo____secao as idtiposecao, T_filho.tfilhoesquerda as tfilho_esquerda
	from 
		(
			SELECT 
				ST.niveis as niveis, ST.filho as filho, ST.esquerda as tfilhoesquerda, ST.direita, ST.id___tipo___secao as id____tipo____secao 
			from 
				(
					SELECT 
						COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita, T.id__tipo__secao as id___tipo___secao
					from 
						(
							SELECT 
								node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita, node.id_tipo_secao as id__tipo__secao 
							from 
								secoes as node, secoes as parent 
									where node.lft BETWEEN parent.lft AND parent.rgt 
						) as T group by T.filho, T.esquerda, T.direita
				) as ST
		) as T_filho 
			left join 
				(
					SELECT 
						ST2.niveis as niveis, ST2.filho as filho, ST2.esquerda, ST2.direita 
					from 
						(
							SELECT 
								COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
							from 
								(
									SELECT 
										node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
									from 
										secoes as node, secoes as parent 
											where node.lft BETWEEN parent.lft AND parent.rgt 

 
								) as T group by T.filho, T.esquerda, T.direita
						) as ST2
				) as T_pai 
					on T_filho.niveis - T_pai.niveis <2 
						where (T_filho.niveis - T_pai.niveis > 0 AND T_filho.tfilhoesquerda BETWEEN T_pai.esquerda AND T_pai.direita) OR (T_filho.niveis=0 AND T_filho.filho = T_pai.filho) ORDER BY T_filho.tfilhoesquerda) AS FINAL WHERE FINAL.idtiposecao IN 
(
SELECT DISTINCT T1.id from (SELECT parent.id_chave_nested_tipo_secao as id FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao in (SELECT T.nome FROM (SELECT node.nome_nested_tipo_secao as nome, (COUNT(parent.nome_nested_tipo_secao) - (min(sub_tree.depth) + 1)) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent, nested_tipos_secoes AS sub_parent, ( SELECT node.nome_nested_tipo_secao, (COUNT(parent.nome_nested_tipo_secao) - 1) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao = tipo_secao GROUP BY node.nome_nested_tipo_secao ORDER BY max(node.lft) ) AS sub_tree WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt AND sub_parent.nome_nested_tipo_secao = sub_tree.nome_nested_tipo_secao GROUP BY node.nome_nested_tipo_secao HAVING depth <= 1 ORDER BY max(node.lft)) as T where T.depth>0)  ORDER BY parent.lft) as T1
) ORDER BY FINAL.tfilho_esquerda;
END
//
#alteracao em elaboracao -> buscar versao na tabela versoes - busca da ultima versao da secao bem sucedida (2022-06-19)
#busca do numero de versoes da secao (2022-06-20)
DROP PROCEDURE IF EXISTS mostra_arvore_niveis_pais_seleciona_tipos_com_filhos_esq_dir
//
CREATE PROCEDURE mostra_arvore_niveis_pais_seleciona_tipos_com_filhos_esq_dir(IN tipo_secao varchar(200))
BEGIN
SELECT POS_FINAL.nivel, POS_FINAL.id_chave_filho, POS_FINAL.id_filho, POS_FINAL.id_pai, POS_FINAL.titulo, POS_FINAL.id_nested_tipo_secao, POS_FINAL.nome_nested_tipo_secao, POS_FINAL.esq, POS_FINAL.dir, POS_FINAL.tem_filho, (SELECT trecho from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as ultima_versao,(SELECT nome_versao from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as data, (SELECT count(*) from versoes where id_secao = POS_FINAL.id_chave_filho) as conta_versoes   FROM
(SELECT FINAL.nivel, FINAL.id_chave_filho, FINAL.id_filho, FINAL.id_pai, FINAL.titulo, FINAL.idtiposecao as id_nested_tipo_secao, (select nome_nested_tipo_secao from nested_tipos_secoes where id_chave_nested_tipo_secao = id_nested_tipo_secao) as nome_nested_tipo_secao, FINAL.tfilho_esquerda as esq, FINAL.tfilho_direita as dir, CASE WHEN (FINAL.tfilho_direita - FINAL.tfilho_esquerda = 1) THEN "NAO_TEM_FILHO" ELSE "TEM_FILHO" END as tem_filho FROM
(
	SELECT 
		T_filho.niveis as nivel, T_filho.id_chave_filho as id_chave_filho, T_filho.filho as id_filho, T_pai.filho as id_pai, (SELECT descricao from secoes where nome_categoria = T_filho.filho) as titulo, T_filho.id____tipo____secao as idtiposecao, T_filho.tfilhoesquerda as tfilho_esquerda, T_filho.tfilhodireita as tfilho_direita
	from 
		(
			SELECT 
				ST.niveis as niveis, ST.id_chave_filho as id_chave_filho, ST.filho as filho, ST.esquerda as tfilhoesquerda, ST.direita as tfilhodireita, ST.id___tipo___secao as id____tipo____secao 
			from 
				(
					SELECT 
						COUNT(T.pai) - 1 as niveis, T.id_chave_filho as id_chave_filho, T.filho as filho, T.esquerda as esquerda, T.direita as direita, T.id__tipo__secao as id___tipo___secao
					from 
						(
							SELECT 
								node.id_chave_categoria as id_chave_filho, node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita, node.id_tipo_secao as id__tipo__secao 
							from 
								secoes as node, secoes as parent 
									where node.lft BETWEEN parent.lft AND parent.rgt 
						) as T group by T.id_chave_filho, T.filho, T.esquerda, T.direita
				) as ST
		) as T_filho 
			left join 
				(
					SELECT 
						ST2.niveis as niveis, ST2.filho as filho, ST2.esquerda, ST2.direita 
					from 
						(
							SELECT 
								COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
							from 
								(
									SELECT 
										node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
									from 
										secoes as node, secoes as parent 
											where node.lft BETWEEN parent.lft AND parent.rgt 

 
								) as T group by T.filho, T.esquerda, T.direita
						) as ST2
				) as T_pai 
					on T_filho.niveis - T_pai.niveis <2 
						where (T_filho.niveis - T_pai.niveis > 0 AND T_filho.tfilhoesquerda BETWEEN T_pai.esquerda AND T_pai.direita) OR (T_filho.niveis=0 AND T_filho.filho = T_pai.filho) ORDER BY T_filho.tfilhoesquerda) AS FINAL WHERE FINAL.idtiposecao IN 
(
SELECT DISTINCT T1.id from (SELECT parent.id_chave_nested_tipo_secao as id FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao in (SELECT T.nome FROM (SELECT node.nome_nested_tipo_secao as nome, (COUNT(parent.nome_nested_tipo_secao) - (min(sub_tree.depth) + 1)) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent, nested_tipos_secoes AS sub_parent, ( SELECT node.nome_nested_tipo_secao, (COUNT(parent.nome_nested_tipo_secao) - 1) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao = tipo_secao GROUP BY node.nome_nested_tipo_secao ORDER BY max(node.lft) ) AS sub_tree WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt AND sub_parent.nome_nested_tipo_secao = sub_tree.nome_nested_tipo_secao GROUP BY node.nome_nested_tipo_secao HAVING depth <= 1 ORDER BY max(node.lft)) as T where T.depth>0)  ORDER BY parent.lft) as T1
) ORDER BY FINAL.tfilho_esquerda) AS POS_FINAL order by POS_FINAL.esq;
END
//
DROP PROCEDURE IF EXISTS mostra_documento_completo_com_pai
//
CREATE PROCEDURE mostra_documento_completo_com_pai(IN tipo_secao varchar(200))
BEGIN
SELECT CASE WHEN (POS_FINAL.nivel=0) THEN 0 ELSE 1 END as nivel, POS_FINAL.id_chave_filho, POS_FINAL.id_filho, POS_FINAL.id_pai as paizao, POS_FINAL.titulo, POS_FINAL.id_nested_tipo_secao, POS_FINAL.nome_nested_tipo_secao, POS_FINAL.esq, POS_FINAL.dir, POS_FINAL.tem_filho, (SELECT trecho from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as ultima_versao,(SELECT nome_versao from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as data, (SELECT count(*) from versoes where id_secao = POS_FINAL.id_chave_filho) as conta_versoes   FROM
(SELECT FINAL.nivel, FINAL.id_chave_filho, FINAL.id_filho, FINAL.id_pai, FINAL.titulo, FINAL.idtiposecao as id_nested_tipo_secao, (select nome_nested_tipo_secao from nested_tipos_secoes where id_chave_nested_tipo_secao = id_nested_tipo_secao) as nome_nested_tipo_secao, FINAL.tfilho_esquerda as esq, FINAL.tfilho_direita as dir, CASE WHEN (FINAL.tfilho_direita - FINAL.tfilho_esquerda = 1) THEN "NAO_TEM_FILHO" ELSE "TEM_FILHO" END as tem_filho FROM
(
	SELECT 
		T_filho.niveis as nivel, T_filho.id_chave_filho as id_chave_filho, T_filho.filho as id_filho, T_pai.filho as id_pai, (SELECT descricao from secoes where nome_categoria = T_filho.filho) as titulo, T_filho.id____tipo____secao as idtiposecao, T_filho.tfilhoesquerda as tfilho_esquerda, T_filho.tfilhodireita as tfilho_direita
	from 
		(
			SELECT 
				ST.niveis as niveis, ST.id_chave_filho as id_chave_filho, ST.filho as filho, ST.esquerda as tfilhoesquerda, ST.direita as tfilhodireita, ST.id___tipo___secao as id____tipo____secao 
			from 
				(
					SELECT 
						COUNT(T.pai) - 1 as niveis, T.id_chave_filho as id_chave_filho, T.filho as filho, T.esquerda as esquerda, T.direita as direita, T.id__tipo__secao as id___tipo___secao
					from 
						(
							SELECT 
								node.id_chave_categoria as id_chave_filho, node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita, node.id_tipo_secao as id__tipo__secao 
							from 
								secoes as node, secoes as parent 
									where node.lft BETWEEN parent.lft AND parent.rgt 
						) as T group by T.id_chave_filho, T.filho, T.esquerda, T.direita
				) as ST
		) as T_filho 
			left join 
				(
					SELECT 
						ST2.niveis as niveis, ST2.filho as filho, ST2.esquerda, ST2.direita 
					from 
						(
							SELECT 
								COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
							from 
								(
									SELECT 
										node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
									from 
										secoes as node, secoes as parent 
											where node.lft BETWEEN parent.lft AND parent.rgt 

 
								) as T group by T.filho, T.esquerda, T.direita
						) as ST2
				) as T_pai 
					on T_filho.niveis - T_pai.niveis <2 
						where (T_filho.niveis - T_pai.niveis > 0 AND T_filho.tfilhoesquerda BETWEEN T_pai.esquerda AND T_pai.direita) OR (T_filho.niveis=0 AND T_filho.filho = T_pai.filho) ORDER BY T_filho.tfilhoesquerda) AS FINAL WHERE FINAL.idtiposecao IN 
(
SELECT DISTINCT T1.id from (SELECT parent.id_chave_nested_tipo_secao as id FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao in (SELECT T.nome FROM (SELECT node.nome_nested_tipo_secao as nome, (COUNT(parent.nome_nested_tipo_secao) - (min(sub_tree.depth) + 1)) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent, nested_tipos_secoes AS sub_parent, ( SELECT node.nome_nested_tipo_secao, (COUNT(parent.nome_nested_tipo_secao) - 1) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao = tipo_secao GROUP BY node.nome_nested_tipo_secao ORDER BY max(node.lft) ) AS sub_tree WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt AND sub_parent.nome_nested_tipo_secao = sub_tree.nome_nested_tipo_secao GROUP BY node.nome_nested_tipo_secao HAVING depth <= 2 ORDER BY max(node.lft)) as T where T.depth>0)  ORDER BY parent.lft) as T1
) ORDER BY FINAL.tfilho_esquerda) AS POS_FINAL order by POS_FINAL.esq;
END
//
DROP PROCEDURE IF EXISTS mostra_documento_completo
//
CREATE PROCEDURE mostra_documento_completo(IN tipo_secao varchar(200))
BEGIN
SELECT CASE WHEN (POS_FINAL.nivel=0) THEN 0 ELSE 1 END as nivel, POS_FINAL.id_chave_filho, POS_FINAL.id_filho, (select "corpo_tese"), POS_FINAL.titulo, POS_FINAL.id_nested_tipo_secao, POS_FINAL.nome_nested_tipo_secao, POS_FINAL.esq, POS_FINAL.dir, POS_FINAL.tem_filho, (SELECT trecho from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as ultima_versao,(SELECT nome_versao from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as data, (SELECT count(*) from versoes where id_secao = POS_FINAL.id_chave_filho) as conta_versoes   FROM
(SELECT FINAL.nivel, FINAL.id_chave_filho, FINAL.id_filho, FINAL.id_pai, FINAL.titulo, FINAL.idtiposecao as id_nested_tipo_secao, (select nome_nested_tipo_secao from nested_tipos_secoes where id_chave_nested_tipo_secao = id_nested_tipo_secao) as nome_nested_tipo_secao, FINAL.tfilho_esquerda as esq, FINAL.tfilho_direita as dir, CASE WHEN (FINAL.tfilho_direita - FINAL.tfilho_esquerda = 1) THEN "NAO_TEM_FILHO" ELSE "TEM_FILHO" END as tem_filho FROM
(
	SELECT 
		T_filho.niveis as nivel, T_filho.id_chave_filho as id_chave_filho, T_filho.filho as id_filho, T_pai.filho as id_pai, (SELECT descricao from secoes where nome_categoria = T_filho.filho) as titulo, T_filho.id____tipo____secao as idtiposecao, T_filho.tfilhoesquerda as tfilho_esquerda, T_filho.tfilhodireita as tfilho_direita
	from 
		(
			SELECT 
				ST.niveis as niveis, ST.id_chave_filho as id_chave_filho, ST.filho as filho, ST.esquerda as tfilhoesquerda, ST.direita as tfilhodireita, ST.id___tipo___secao as id____tipo____secao 
			from 
				(
					SELECT 
						COUNT(T.pai) - 1 as niveis, T.id_chave_filho as id_chave_filho, T.filho as filho, T.esquerda as esquerda, T.direita as direita, T.id__tipo__secao as id___tipo___secao
					from 
						(
							SELECT 
								node.id_chave_categoria as id_chave_filho, node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita, node.id_tipo_secao as id__tipo__secao 
							from 
								secoes as node, secoes as parent 
									where node.lft BETWEEN parent.lft AND parent.rgt 
						) as T group by T.id_chave_filho, T.filho, T.esquerda, T.direita
				) as ST
		) as T_filho 
			left join 
				(
					SELECT 
						ST2.niveis as niveis, ST2.filho as filho, ST2.esquerda, ST2.direita 
					from 
						(
							SELECT 
								COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
							from 
								(
									SELECT 
										node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
									from 
										secoes as node, secoes as parent 
											where node.lft BETWEEN parent.lft AND parent.rgt 

 
								) as T group by T.filho, T.esquerda, T.direita
						) as ST2
				) as T_pai 
					on T_filho.niveis - T_pai.niveis <2 
						where (T_filho.niveis - T_pai.niveis > 0 AND T_filho.tfilhoesquerda BETWEEN T_pai.esquerda AND T_pai.direita) OR (T_filho.niveis=0 AND T_filho.filho = T_pai.filho) ORDER BY T_filho.tfilhoesquerda) AS FINAL WHERE FINAL.idtiposecao IN 
(
SELECT DISTINCT T1.id from (SELECT parent.id_chave_nested_tipo_secao as id FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao in (SELECT T.nome FROM (SELECT node.nome_nested_tipo_secao as nome, (COUNT(parent.nome_nested_tipo_secao) - (min(sub_tree.depth) + 1)) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent, nested_tipos_secoes AS sub_parent, ( SELECT node.nome_nested_tipo_secao, (COUNT(parent.nome_nested_tipo_secao) - 1) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao = tipo_secao GROUP BY node.nome_nested_tipo_secao ORDER BY max(node.lft) ) AS sub_tree WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt AND sub_parent.nome_nested_tipo_secao = sub_tree.nome_nested_tipo_secao GROUP BY node.nome_nested_tipo_secao HAVING depth <= 2 ORDER BY max(node.lft)) as T where T.depth>0)  ORDER BY parent.lft) as T1
) ORDER BY FINAL.tfilho_esquerda) AS POS_FINAL order by POS_FINAL.esq;
END
//
DROP PROCEDURE IF EXISTS mostra_documento_completo_niveis
//
CREATE PROCEDURE mostra_documento_completo_niveis(IN tipo_secao varchar(200))
BEGIN
SELECT POS_FINAL.nivel as nivel, POS_FINAL.id_chave_filho, POS_FINAL.id_filho, (select "corpo_tese"), POS_FINAL.titulo as primeira_versao, POS_FINAL.id_nested_tipo_secao, POS_FINAL.nome_nested_tipo_secao, POS_FINAL.esq, POS_FINAL.dir, POS_FINAL.tem_filho, (SELECT trecho from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as ultima_versao,(SELECT nome_versao from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as data, (SELECT count(*) from versoes where id_secao = POS_FINAL.id_chave_filho) as conta_versoes   FROM
(SELECT FINAL.nivel, FINAL.id_chave_filho, FINAL.id_filho, FINAL.id_pai, FINAL.titulo, FINAL.idtiposecao as id_nested_tipo_secao, (select nome_nested_tipo_secao from nested_tipos_secoes where id_chave_nested_tipo_secao = id_nested_tipo_secao) as nome_nested_tipo_secao, FINAL.tfilho_esquerda as esq, FINAL.tfilho_direita as dir, CASE WHEN (FINAL.tfilho_direita - FINAL.tfilho_esquerda = 1) THEN "NAO_TEM_FILHO" ELSE "TEM_FILHO" END as tem_filho FROM
(
	SELECT 
		T_filho.niveis as nivel, T_filho.id_chave_filho as id_chave_filho, T_filho.filho as id_filho, T_pai.filho as id_pai, (SELECT descricao from secoes where nome_categoria = T_filho.filho) as titulo, T_filho.id____tipo____secao as idtiposecao, T_filho.tfilhoesquerda as tfilho_esquerda, T_filho.tfilhodireita as tfilho_direita
	from 
		(
			SELECT 
				ST.niveis as niveis, ST.id_chave_filho as id_chave_filho, ST.filho as filho, ST.esquerda as tfilhoesquerda, ST.direita as tfilhodireita, ST.id___tipo___secao as id____tipo____secao 
			from 
				(
					SELECT 
						COUNT(T.pai) - 1 as niveis, T.id_chave_filho as id_chave_filho, T.filho as filho, T.esquerda as esquerda, T.direita as direita, T.id__tipo__secao as id___tipo___secao
					from 
						(
							SELECT 
								node.id_chave_categoria as id_chave_filho, node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita, node.id_tipo_secao as id__tipo__secao 
							from 
								secoes as node, secoes as parent 
									where node.lft BETWEEN parent.lft AND parent.rgt 
						) as T group by T.id_chave_filho, T.filho, T.esquerda, T.direita
				) as ST
		) as T_filho 
			left join 
				(
					SELECT 
						ST2.niveis as niveis, ST2.filho as filho, ST2.esquerda, ST2.direita 
					from 
						(
							SELECT 
								COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
							from 
								(
									SELECT 
										node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
									from 
										secoes as node, secoes as parent 
											where node.lft BETWEEN parent.lft AND parent.rgt 

 
								) as T group by T.filho, T.esquerda, T.direita
						) as ST2
				) as T_pai 
					on T_filho.niveis - T_pai.niveis <2 
						where (T_filho.niveis - T_pai.niveis > 0 AND T_filho.tfilhoesquerda BETWEEN T_pai.esquerda AND T_pai.direita) OR (T_filho.niveis=0 AND T_filho.filho = T_pai.filho) ORDER BY T_filho.tfilhoesquerda) AS FINAL WHERE FINAL.idtiposecao IN 
(
SELECT DISTINCT T1.id from (SELECT parent.id_chave_nested_tipo_secao as id FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao in (SELECT T.nome FROM (SELECT node.nome_nested_tipo_secao as nome, (COUNT(parent.nome_nested_tipo_secao) - (min(sub_tree.depth) + 1)) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent, nested_tipos_secoes AS sub_parent, ( SELECT node.nome_nested_tipo_secao, (COUNT(parent.nome_nested_tipo_secao) - 1) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao = tipo_secao GROUP BY node.nome_nested_tipo_secao ORDER BY max(node.lft) ) AS sub_tree WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt AND sub_parent.nome_nested_tipo_secao = sub_tree.nome_nested_tipo_secao GROUP BY node.nome_nested_tipo_secao HAVING depth <= 2 ORDER BY max(node.lft)) as T where T.depth>0)  ORDER BY parent.lft) as T1
) ORDER BY FINAL.tfilho_esquerda) AS POS_FINAL order by POS_FINAL.esq;
END
//
DROP PROCEDURE IF EXISTS mostra_documento_completo_niveis_sem_lixeira
//
CREATE PROCEDURE mostra_documento_completo_niveis_sem_lixeira(IN tipo_secao varchar(200))
BEGIN
CALL mostra_arvore_abaixo_secao("lixeira");
SELECT POS_FINAL.nivel as nivel, POS_FINAL.id_chave_filho, POS_FINAL.id_filho, (select "corpo_tese"), POS_FINAL.titulo as primeira_versao, POS_FINAL.id_nested_tipo_secao, POS_FINAL.nome_nested_tipo_secao, POS_FINAL.esq, POS_FINAL.dir, POS_FINAL.tem_filho, (SELECT trecho from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as ultima_versao,(SELECT nome_versao from versoes where id_secao = POS_FINAL.id_chave_filho order by nome_versao DESC LIMIT 1) as data, (SELECT count(*) from versoes where id_secao = POS_FINAL.id_chave_filho) as conta_versoes   FROM
(SELECT FINAL.nivel, FINAL.id_chave_filho, FINAL.id_filho, FINAL.id_pai, FINAL.titulo, FINAL.idtiposecao as id_nested_tipo_secao, (select nome_nested_tipo_secao from nested_tipos_secoes where id_chave_nested_tipo_secao = id_nested_tipo_secao) as nome_nested_tipo_secao, FINAL.tfilho_esquerda as esq, FINAL.tfilho_direita as dir, CASE WHEN (FINAL.tfilho_direita - FINAL.tfilho_esquerda = 1) THEN "NAO_TEM_FILHO" ELSE "TEM_FILHO" END as tem_filho FROM
(
	SELECT 
		T_filho.niveis as nivel, T_filho.id_chave_filho as id_chave_filho, T_filho.filho as id_filho, T_pai.filho as id_pai, (SELECT descricao from secoes where nome_categoria = T_filho.filho) as titulo, T_filho.id____tipo____secao as idtiposecao, T_filho.tfilhoesquerda as tfilho_esquerda, T_filho.tfilhodireita as tfilho_direita
	from 
		(
			SELECT 
				ST.niveis as niveis, ST.id_chave_filho as id_chave_filho, ST.filho as filho, ST.esquerda as tfilhoesquerda, ST.direita as tfilhodireita, ST.id___tipo___secao as id____tipo____secao 
			from 
				(
					SELECT 
						COUNT(T.pai) - 1 as niveis, T.id_chave_filho as id_chave_filho, T.filho as filho, T.esquerda as esquerda, T.direita as direita, T.id__tipo__secao as id___tipo___secao
					from 
						(
							SELECT 
								node.id_chave_categoria as id_chave_filho, node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita, node.id_tipo_secao as id__tipo__secao 
							from 
								secoes as node, secoes as parent 
									where node.lft BETWEEN parent.lft AND parent.rgt 
						) as T group by T.id_chave_filho, T.filho, T.esquerda, T.direita
				) as ST
		) as T_filho 
			left join 
				(
					SELECT 
						ST2.niveis as niveis, ST2.filho as filho, ST2.esquerda, ST2.direita 
					from 
						(
							SELECT 
								COUNT(T.pai) - 1 as niveis, T.filho as filho, T.esquerda as esquerda, T.direita as direita 
							from 
								(
									SELECT 
										node.nome_categoria as filho, parent.nome_categoria as pai, node.lft as esquerda, node.rgt as direita 
									from 
										secoes as node, secoes as parent 
											where node.lft BETWEEN parent.lft AND parent.rgt 

 
								) as T group by T.filho, T.esquerda, T.direita
						) as ST2
				) as T_pai 
					on T_filho.niveis - T_pai.niveis <2 
						where (T_filho.niveis - T_pai.niveis > 0 AND T_filho.tfilhoesquerda BETWEEN T_pai.esquerda AND T_pai.direita) OR (T_filho.niveis=0 AND T_filho.filho = T_pai.filho) ORDER BY T_filho.tfilhoesquerda) AS FINAL WHERE FINAL.idtiposecao IN 
(
SELECT DISTINCT T1.id from (SELECT parent.id_chave_nested_tipo_secao as id FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao in (SELECT T.nome FROM (SELECT node.nome_nested_tipo_secao as nome, (COUNT(parent.nome_nested_tipo_secao) - (min(sub_tree.depth) + 1)) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent, nested_tipos_secoes AS sub_parent, ( SELECT node.nome_nested_tipo_secao, (COUNT(parent.nome_nested_tipo_secao) - 1) AS depth FROM nested_tipos_secoes AS node, nested_tipos_secoes AS parent WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.nome_nested_tipo_secao = tipo_secao GROUP BY node.nome_nested_tipo_secao ORDER BY max(node.lft) ) AS sub_tree WHERE node.lft BETWEEN parent.lft AND parent.rgt AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt AND sub_parent.nome_nested_tipo_secao = sub_tree.nome_nested_tipo_secao GROUP BY node.nome_nested_tipo_secao HAVING depth <= 2 ORDER BY max(node.lft)) as T where T.depth>0)  ORDER BY parent.lft) as T1
) ORDER BY FINAL.tfilho_esquerda) AS POS_FINAL WHERE POS_FINAL.id_chave_filho not in(select id_da_secao_da_lixeira from guarda_ids_da_lixeira) order by POS_FINAL.esq;
END
//

DELIMITER ;

DROP TABLE IF EXISTS guarda_ids_da_lixeira; # preciso saber os ids da lixeira para não imprimir a lixeira no LATEX
DROP TABLE IF EXISTS ids_de_referencia;
DROP TABLE IF EXISTS versoes;
DROP TABLE IF EXISTS instancias_propriedades; # a ordem é importante por causa do foreign key
DROP TABLE IF EXISTS valores_discretos; # a ordem é importante por causa do foreign key
DROP TABLE IF EXISTS propriedades; # a ordem é importante por causa do foreign key
DROP TABLE IF EXISTS secoes; # a ordem é importante por causa do foreign key
DROP TABLE IF EXISTS nested_tipos_secoes; # a ordem é importante por causa do foreign key

CREATE TABLE users (
	id_chave_user INT AUTO_INCREMENT PRIMARY KEY,
	nome_user VARCHAR(100),
	senha VARCHAR(300),
	UNIQUE(nome_user)
);

INSERT INTO users (nome_user, senha) VALUES ("pedro","$2y$10$EECgzrOjZDADL35JU9kLaOmiOtSNuPP1FP9rlQlmheGuLpyr7qHRu");
INSERT INTO users (nome_user, senha) VALUES ("victor","$2y$10$EECgzrOjZDADL35JU9kLaOmiOtSNuPP1FP9rlQlmheGuLpyr7qHRu");

CREATE TABLE propriedades (
	id_chave_propriedade INT AUTO_INCREMENT PRIMARY KEY,
	nome_propriedade VARCHAR(100),
	UNIQUE(nome_propriedade)
);

INSERT INTO propriedades (nome_propriedade) VALUES ("alinhamento");
INSERT INTO propriedades (nome_propriedade) VALUES ("tamanho_fonte");
INSERT INTO propriedades (nome_propriedade) VALUES ("tipo_fonte");
INSERT INTO propriedades (nome_propriedade) VALUES ("posicao_vert");
INSERT INTO propriedades (nome_propriedade) VALUES ("tipo_numeracao");
INSERT INTO propriedades (nome_propriedade) VALUES ("eh_paragrafo");
INSERT INTO propriedades (nome_propriedade) VALUES ("margem_simetrica");

CREATE TABLE valores_discretos (
	id_chave_valor_discreto INT AUTO_INCREMENT PRIMARY KEY,
	nome_valor_discreto varchar(100),
	id_propriedade INT,
	FOREIGN KEY (id_propriedade) REFERENCES propriedades(id_chave_propriedade)

);

INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("normal",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("italico",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("bold",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("sublinhado",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_fonte"));

INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("direita",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "alinhamento"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("esquerda",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "alinhamento"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("centro",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "alinhamento"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("justificado",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "alinhamento"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("0.7",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("0.8",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("0.9",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.0",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.1",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.2",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.3",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.4",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.5",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.6",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.7",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.8",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("1.9",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.0",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.1",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.2",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.3",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.4",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.5",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.6",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.7",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.8",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("2.9",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("3.0",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("3.1",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("3.2",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("3.3",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("3.4",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("3.5",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tamanho_fonte"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("cima",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "posicao_vert"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("baixo",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "posicao_vert"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("centro",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "posicao_vert"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("letra_i",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_numeracao"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("letra_a",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_numeracao"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("letra_I",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_numeracao"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("romana",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_numeracao"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("algarismo",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "tipo_numeracao"));

INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("10%",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "margem_simetrica"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("15%",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "margem_simetrica"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("20%",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "margem_simetrica"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("25%",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "margem_simetrica"));

INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("sim",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "eh_paragrafo"));
INSERT INTO valores_discretos (nome_valor_discreto, id_propriedade) VALUES ("nao",(SELECT id_chave_propriedade FROM propriedades WHERE nome_propriedade = "eh_paragrafo"));


CREATE TABLE nested_tipos_secoes (
        id_chave_nested_tipo_secao INT AUTO_INCREMENT PRIMARY KEY,
        nome_nested_tipo_secao VARCHAR(200) NOT NULL,
	descricao varchar(10000),
        lft INT NOT NULL,
        rgt INT NOT NULL
);

INSERT INTO nested_tipos_secoes VALUES(1,'raiz','Rais dos Tipos de Secao',1,2);
#,(2,'topico',2,15),(3,'paragrafo',3,4), (4,'imagem',5,6),(5,'grafico',7,8),(6,'tabela',9,10),(7,'lista',11,14),(8,'item',12,13);

call insere_a_direita_dos_filhos_tipos_secoes("raiz",				"capa",						"Capa do documento");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"titulo",					"Titulo Principal do Documento");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"titulo_abstract",				"Titulo do abstract em inglês");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"sub_titulo",					"Sub-Titulo do Documento");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"autor",					"Autor do Documento");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"autor_abr",					"Abreviatura do Autor do Documento (e.g. SILVA, J.)");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"autor_ficha",					"Autor do Documento para Ficha Catalográfica (e.g. Silva, José da)");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"orientador",					"Orientador do Documento");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"orientador_ficha",				"Abreviatura do Orientador para Ficha Catalográfica (e.g. Silva, José da)");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"coorientador",					"Coorientador do Documento");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"programa_pos",					"Nome do programa de pós-graduação");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"programa_pos_maiuscula",			"Nome do programa de pós-graduação em maiusculas");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"curso",					"Curso onde autor está matriculado");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"curso_maiuscula",				"Curso onde autor está matriculado em maiúsculas");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"mestre_ou_doutor",				"Escreva Mestre ou Doutor");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"titulo_pos",					"Descrever o titulo alcançado: Mestre em Engenharia, etc.");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"universidade",					"Nome da Universidade");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"universidade_maiuscula",			"Nome da Universidade em maiúsculas");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"unidade_faculdade",				"Nome da unidade ou faculdade dentro da Universidade");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"unidade_faculdade_maiuscula",			"Nome da unidade ou faculdade dentro da Universidade em maiúscula");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"localidade",					"Nome da cidade onde fica a universidade");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"ano",						"Ano da defesa da tese");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"palavras_chave",				"Palavras-chave da tese ou dissertação");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"epigrafe",					"Frase que dá o mote da obra.");
call insere_a_direita_dos_filhos_tipos_secoes("capa",				"dedicatoria",					"Frase de dedicatória.");
call insere_a_direita_dos_filhos_tipos_secoes("raiz",				"agradecimento",				"Agradecimentos");
call insere_a_direita_dos_filhos_tipos_secoes("agradecimento",			"paragrafo_agradecimento", 			"Parágrafos do agradecimentos");
call insere_a_direita_dos_filhos_tipos_secoes("raiz",				"resumo",					"Resumo");
call insere_a_direita_dos_filhos_tipos_secoes("resumo",				"paragrafo_resumo", 				"Paragrafos do Resumo");
call insere_a_direita_dos_filhos_tipos_secoes("raiz",				"abstract",					"Abstract");
call insere_a_direita_dos_filhos_tipos_secoes("abstract",			"paragrafo_abstract", 				"Parágrafos do Abstract");
call insere_a_direita_dos_filhos_tipos_secoes("raiz",				"lista_de_tab_fig",				"Listas genéricas do começo da tese, incluindo glossário");
call insere_a_direita_dos_filhos_tipos_secoes("lista_de_tab_fig",		"item_lista_de_tab_fig", 			"Itens das listas de tabelas, figuras, etc.");
call insere_a_direita_dos_filhos_tipos_secoes("raiz",				"indice",					"Índice");
call insere_a_direita_dos_filhos_tipos_secoes("indice",				"item_indice", 					"Itens do Índice");
call insere_a_direita_dos_filhos_tipos_secoes("raiz",				"topico",					"Tópicos ou Seções incluindo capítulos");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"paragrafo",					"Parágrafos dos tópicos ou das sessões");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"chama_ref",					"Chamada de referência em parágrafos dos tópicos ou das sessões");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"citacao",					"Citacao por extenso em itálico, dentro de tópicos ou das sessões");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"imagem",					"Imagens dos tópicos ou sessões");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"mult_imagem",					"Imagens múltiplas, arquivo e captions separados por |");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"legenda_imagem",				"Legenda de Imagens dos tópicos ou sessões");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"grafico",					"Gráficos dos tópicos ou sessões");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"legenda_grafico",				"Legenda de gráficos dos tópicos ou sessões");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"tabela",					"Tabelas dos tópicos ou sessões");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"legenda_tabela",				"Legenda de tabela dos tópicos ou sessões");

call insere_a_direita_dos_filhos_tipos_secoes("topico",				"diagrama_MER",					"Diagrama MER");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"diagrama_MER_3ario",					"Diagrama MER ternário");
call insere_a_direita_dos_filhos_tipos_secoes("topico",             "diagrama_MER_quad",                   "Diagrama MER quaternário");

call insere_a_direita_dos_filhos_tipos_secoes("topico",				"item_lista_num",				"Item de Lista Numerada");
call insere_a_direita_dos_filhos_tipos_secoes("topico",				"item_lista_nao_num",				"Item de Lista Numerada");
call insere_a_direita_dos_filhos_tipos_secoes("topico",			    "item_de_referencia", 				"Itens da seção de referências");

CREATE TABLE instancias_propriedades (
	id_chave_instancia_propriedade INT AUTO_INCREMENT PRIMARY KEY,
	valor_continuo varchar(50),
	id_propriedade INT,
	id_valor_discreto INT,
	id_nested_tipo_secao INT,
	UNIQUE(id_propriedade, id_nested_tipo_secao),
	FOREIGN KEY (id_propriedade) REFERENCES propriedades(id_chave_propriedade),
	FOREIGN KEY (id_valor_discreto) REFERENCES valores_discretos(id_chave_valor_discreto),
	FOREIGN KEY (id_nested_tipo_secao) REFERENCES nested_tipos_secoes(id_chave_nested_tipo_secao)
); 


INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="capa"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "centro"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="capa"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "2.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="capa"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "normal"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="capa"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="agradecimento"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "justificado"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="agradecimento"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "1.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="agradecimento"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "normal"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="agradecimento"));


INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="resumo"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "justificado"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="resumo"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "1.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="resumo"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "normal"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="resumo"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="abstract"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "justificado"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="abstract"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "1.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="abstract"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "normal"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="abstract"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="lista_de_tab_fig"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "justificado"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="lista_de_tab_fig"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "1.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="lista_de_tab_fig"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "normal"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="lista_de_tab_fig"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="indice"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "justificado"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="indice"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "1.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="indice"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "normal"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="indice"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="topico"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "justificado"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="topico"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "1.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="topico"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "bold"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="topico"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "sim"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="paragrafo"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "justificado"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="paragrafo"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "1.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="paragrafo"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "normal"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="paragrafo"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "sim"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="chama_ref"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "direita"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="chama_ref"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "0.7"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="chama_ref"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "normal"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="chama_ref"));



INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "sim"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="legenda_imagem"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "centro"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="legenda_imagem"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "0.7"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="legenda_imagem"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "bold"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="legenda_imagem"));


INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "sim"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="citacao"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "justificado"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="citacao"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "1.0"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="citacao"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tipo_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tipo_fonte" AND B.nome_valor_discreto = "italico"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="citacao"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="imagem"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "centro"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="imagem"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="grafico"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "centro"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="grafico"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="tabela"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "centro"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="tabela"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "esquerda"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="item_lista_num"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="item_lista_num"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="tamanho_fonte"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "tamanho_fonte" AND B.nome_valor_discreto = "0.8"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="item_lista_num"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="margem_simetrica"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "margem_simetrica" AND B.nome_valor_discreto = "20%"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="item_lista_num"));

INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="alinhamento"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "alinhamento" AND B.nome_valor_discreto = "esquerda"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="item_lista_nao_num"));
INSERT INTO instancias_propriedades (valor_continuo,id_propriedade, id_valor_discreto, id_nested_tipo_secao) VALUES ("",(SELECT id_chave_propriedade FROM propriedades where nome_propriedade="eh_paragrafo"),(SELECT id_chave_valor_discreto FROM propriedades as A, valores_discretos as B WHERE B.id_propriedade = A.id_chave_propriedade AND A.nome_propriedade = "eh_paragrafo" AND B.nome_valor_discreto = "nao"),(SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes where nome_nested_tipo_secao ="item_lista_nao_num"));

CREATE TABLE secoes (
        id_chave_categoria INT AUTO_INCREMENT PRIMARY KEY,
        nome_categoria VARCHAR(100) NOT NULL,
	descricao varchar(3500),
	lnk varchar(300),
        lft INT NOT NULL,
        rgt INT NOT NULL,
	id_tipo_secao int,
	unique(nome_categoria),
	FOREIGN KEY (id_tipo_secao) REFERENCES nested_tipos_secoes(id_chave_nested_tipo_secao)
);

create table guarda_ids_da_lixeira(
			id_chave_guarda_id_da_lixeira int auto_increment primary key,
			id_da_secao_da_lixeira int,
			foreign key (id_da_secao_da_lixeira) references secoes(id_chave_categoria)
		);

CREATE TABLE ids_de_referencia(
		id_chave_id_de_referencia INT AUTO_INCREMENT PRIMARY KEY,
		nome_id_de_referencia VARCHAR(300) DEFAULT NULL,
		id_secao_do_identificador INT,
		unique(nome_id_de_referencia),
		unique(id_secao_do_identificador),
		FOREIGN KEY (id_secao_do_identificador) REFERENCES secoes(id_chave_categoria)
		);
		


CREATE TABLE versoes(
	id_chave_versao int not null auto_increment PRIMARY KEY,
	nome_versao TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
	id_secao int,
	trecho varchar(3500),
	unique (id_secao, nome_versao),
	FOREIGN KEY (id_secao) REFERENCES secoes(id_chave_categoria) 
);

DROP TRIGGER IF EXISTS grava_id_de_referencia;

# o trigger abaixo preenche a tabela ids_de_referencia com os identificadores das referencias que sao do tipo item_de_referencia, pegando apenas o que estah entre colchetes, sempre que houver a insercao de uma nova versao com insert into versoes
# note que nao ha correcao do identificador se houver update da tabela versoes, mas o RedarTex nao faz update das linhas da tabela versao. Sempre que uma nova versao eh criada, uma nova linha eh criada na tabela versao.

DELIMITER $$
CREATE TRIGGER grava_id_de_referencia
BEFORE INSERT ON versoes
FOR EACH ROW
BEGIN
	DECLARE c varchar(26) DEFAULT "abcdefghijklmnopqrstuvwxyz";
	DECLARE conta INT DEFAULT 0;
	DECLARE conta2 INT DEFAULT 0;
	DECLARE identificador varchar(200) DEFAULT "";
	DECLARE velho_identificador varchar(200) DEFAULT "";
	DECLARE TEMP varchar(200) DEFAULT "";	
	IF  NEW.id_secao IN (SELECT id_chave_categoria from secoes where id_tipo_secao = (SELECT id_chave_nested_tipo_secao FROM nested_tipos_secoes WHERE nome_nested_tipo_secao = "item_de_referencia")) THEN
    DELETE FROM ids_de_referencia WHERE id_secao_do_identificador = NEW.id_secao; # tem que apagar se eh uma atualizacao de versao, porque pode ser que o identificador seja mantido e ai nao queremos que coloque letras caso seja soh uma atualizacao da referencia bibliografica	
	SET identificador =  SUBSTRING(NEW.trecho, position("[" IN NEW.trecho)+1, position("]" IN NEW.trecho) - position("[" IN NEW.trecho) -1);
	SET velho_identificador = identificador;
	SET temp = identificador;
	WHILE temp IN (SELECT nome_id_de_referencia from ids_de_referencia) DO
	 IF conta > 26 THEN
	 	SET conta2 = conta2 + 1;
	 	SET identificador = CONCAT(identificador, SUBSTR(c, conta2, 1));
		SET conta=0;
	 END IF;
	 SET conta = conta + 1;
	 SET temp = CONCAT(identificador, SUBSTR(c,conta,1));
	 IF conta2>26 THEN
	 	SET conta2=0;
	 END IF;
	END WHILE;
	SET identificador = temp;
	INSERT INTO ids_de_referencia (nome_id_de_referencia, id_secao_do_identificador) VALUES 
			(
				(
				CASE 	
					WHEN identificador = "" THEN NULL
					ELSE identificador 
			 	END
				)
			,
			NEW.id_secao
			)  
			ON DUPLICATE KEY 
			UPDATE nome_id_de_referencia = 
			CASE 	
				WHEN identificador = "" THEN NULL
				ELSE identificador 
		 	END
			,
			id_secao_do_identificador = NEW.id_secao;
  	SET NEW.trecho = REPLACE(NEW.trecho, CONCAT("[",velho_identificador,"]"), CONCAT("[",identificador,"]"));
	END IF;
	END$$

DELIMITER ;

# importante -> nao pode usar traço no primary key do nome_categoria
# CREATE PROCEDURE insere_a_direita_dos_filhos(IN nome_no_pai varchar(100), IN no_para_inserir varchar(100), IN no_descricao varchar(10000), IN no_link varchar(300), IN tipo_secao int)


insert into secoes values (1,'corpo_tese','raiz','',1,2, (SELECT id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao="raiz"));


call insere_a_direita_dos_filhos("corpo_tese", "capa_da_tese", "Capa da Tese" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "capa"));
call insere_a_direita_dos_filhos("capa_da_tese", "titulo_da_tese", "CARACTERIZAÇÃO DO PROGRAMA Workshop Aficionados por Software e Hardware (WASH)" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "titulo"));
call insere_a_direita_dos_filhos("capa_da_tese", "sub_titulo_da_tese", "HISTÓRIA, MÉTODOS E RESULTADOS" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "sub_titulo"));
call insere_a_direita_dos_filhos("capa_da_tese", "autor_da_tese", "Elaine da Silva Tozzi" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "autor"));
call insere_a_direita_dos_filhos("capa_da_tese", "autor_abreviatura", "Tozzi, E.S." , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "autor_abr"));
call insere_a_direita_dos_filhos("capa_da_tese", "autor_ficha_catalografica", "Tozzi, Elaine da Silva" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "autor_ficha"));
call insere_a_direita_dos_filhos("capa_da_tese", "titulo_do_abstract", "Characterization of the Hardware and Software for Geeks Program " , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "titulo_abstract"));
call insere_a_direita_dos_filhos("capa_da_tese", "orientador_da_tese", "Paulo Sérgio Camargo" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "orientador"));
call insere_a_direita_dos_filhos("capa_da_tese", "orientador_ficha_catalografica", "Camargo, Paulo Sérgio" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "orientador_ficha"));
call insere_a_direita_dos_filhos("capa_da_tese", "programa_de_pos_graduacao", "Programa de Pós-Graduação da UTFPR" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "programa_pos"));
call insere_a_direita_dos_filhos("capa_da_tese", "programa_de_pos_graduacao_maiusculas", "PROGRAMA DE PÓS-GRADUAÇÃO DA UTFPR" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "programa_pos_maiuscula"));
call insere_a_direita_dos_filhos("capa_da_tese", "curso_matriculado", "Curso de Pós-Graduação em Licenciatura" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "curso"));
call insere_a_direita_dos_filhos("capa_da_tese", "curso_matriculado_maiuscula", "CURSO DE PÓS-GRADUAÇÃO EM LICENCIATURA" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "curso_maiuscula"));
call insere_a_direita_dos_filhos("capa_da_tese", "indique_mestre_ou_doutor", "Mestre" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "mestre_ou_doutor"));
call insere_a_direita_dos_filhos("capa_da_tese", "titulo_da_pos_graduacao", "Mestre em Licenciatura" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "titulo_pos"));
call insere_a_direita_dos_filhos("capa_da_tese", "nome_da_universidade", "Universidade Tecnológica Federal do Paraná" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "universidade"));
call insere_a_direita_dos_filhos("capa_da_tese", "nome_da_universidade_maiuscula", "UNIVERSIDADE TECNOLÓGICA FEDERAL DO PARANÁ" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "universidade_maiuscula"));
call insere_a_direita_dos_filhos("capa_da_tese", "nome_da_unidade", "Faculdade de Educação" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "unidade_faculdade"));
call insere_a_direita_dos_filhos("capa_da_tese", "nome_da_unidade_maiuscula", "FACULDADE DE EDUCAÇÃO" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "unidade_faculdade_maiuscula"));
call insere_a_direita_dos_filhos("capa_da_tese", "nome_da_localidade", "Londrina" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "localidade"));
call insere_a_direita_dos_filhos("capa_da_tese", "lista_palavras_chave", "Papert, STEAM, STEM, WASH" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "palavras_chave"));
call insere_a_direita_dos_filhos("capa_da_tese", "frase_epigrafe", "Ciência é a compreensão que o outro constrói sobre o conhecimento de alguém." , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "epigrafe"));
call insere_a_direita_dos_filhos("capa_da_tese", "frase_dedicatoria", "Dedico esta dissertação aos meus pais." , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "dedicatoria"));
call insere_a_direita_dos_filhos("capa_da_tese", "ano_de_defesa", "2022" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "ano"));
call insere_a_direita_dos_filhos("corpo_tese", "agradecimento_da_tese", "Agradecimentos" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "agradecimento"));
call insere_a_direita_dos_filhos("agradecimento_da_tese", "paragrafo_agradecimento_1", "Gostaria de agradecer meus pais por tudo que me propiciaram." , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "paragrafo_agradecimento"));
call insere_a_direita_dos_filhos("corpo_tese", "resumo_da_tese", "RESUMO" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "resumo"));
call insere_a_direita_dos_filhos("resumo_da_tese", "paragrafo_res_1", "Neste trabalho o Programa Workshop de Aficcionados em Software e Hardware será caracterizado quanto à sua história, métodos e resultados." , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "paragrafo_resumo"));
call insere_a_direita_dos_filhos("corpo_tese", "presidencia", "Presidência" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "topico"));
call insere_a_direita_dos_filhos("presidencia", "descricao_presidencia", "Presidência da Fundacentro" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "paragrafo"));
call insere_a_direita_dos_filhos("presidencia", "Gabinete", "Gabinete" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "topico"));

call insere_a_direita_dos_filhos("corpo_tese", "lixeira", "Lixeira" , "",(select id_chave_nested_tipo_secao from nested_tipos_secoes where nome_nested_tipo_secao = "topico"));


INSERT INTO versoes (id_secao, trecho) SELECT id_chave_categoria, descricao FROM secoes;

call mostra_arvore();
call mostra_arvore_niveis();
call mostra_arvore_niveis_pais();
#call mostra_arvore_niveis_pais_segrega_tipo("paragrafo");

call mostra_arvore_niveis_pais_seleciona_tipo("paragrafo");
call mostra_arvore_niveis_pais_seleciona_tipo("raiz");
call mostra_arvore_niveis_pais_seleciona_tipo("topico");


SELECT parent.nome_nested_tipo_secao, parent.id_chave_nested_tipo_secao
FROM nested_tipos_secoes AS node,
        nested_tipos_secoes AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rgt
        AND node.nome_nested_tipo_secao = 'item'
ORDER BY parent.lft;

call mostra_arvore_tipos_secoes();
call mostra_arvore_niveis_tipos_secoes();

select * from ids_de_referencia,versoes where id_secao_do_identificador = id_secao;
