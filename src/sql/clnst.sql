# Sistema de gestão de propostas


DROP TABLE IF EXISTS versoes;
DROP TABLE IF EXISTS propostas;
DROP TABLE IF EXISTS grupos_diretrizes;
DROP TABLE IF EXISTS eixos_diretrizes;
DROP TABLE IF EXISTS diretrizes;
DROP TABLE IF EXISTS grupos;
DROP TABLE IF EXISTS eixos;
DROP TABLE IF EXISTS users;

		CREATE TABLE users (
			id_chave_user INT AUTO_INCREMENT PRIMARY KEY,
			nome_user VARCHAR(100),
			senha VARCHAR(300),
			UNIQUE(nome_user)
		);

		INSERT INTO users (nome_user, senha) VALUES ("pedro","$2y$10$EECgzrOjZDADL35JU9kLaOmiOtSNuPP1FP9rlQlmheGuLpyr7qHRu");
		INSERT INTO users (nome_user, senha) VALUES ("victor","$2y$10$EECgzrOjZDADL35JU9kLaOmiOtSNuPP1FP9rlQlmheGuLpyr7qHRu");

		CREATE TABLE eixos (
			id_chave_eixo INT AUTO_INCREMENT PRIMARY KEY,
			nome_eixo VARCHAR(100),
			descricao VARCHAR(1000),
			UNIQUE(nome_eixo)
		);

		INSERT INTO eixos (nome_eixo, descricao) VALUES ("Tema I", "O Brasil que temos. O Brasil que queremos;");
		INSERT INTO eixos (nome_eixo, descricao) VALUES ("Tema II", "O papel do controle social e dos movimentos sociais para salvar vidas");
		INSERT INTO eixos (nome_eixo, descricao) VALUES ("Tema III", "Garantir direitos e defender o SUS, a vida e a democracia");
		INSERT INTO eixos (nome_eixo, descricao) VALUES ("Tema IV", "Amanhã vai ser outro dia para todas as pessoas");

		CREATE TABLE diretrizes		 (
			id_chave_diretriz INT AUTO_INCREMENT PRIMARY KEY,
			nome_diretriz varchar(100),
			descricao VARCHAR(1000),
			unique(nome_diretriz)
		);

		INSERT INTO diretrizes (nome_diretriz, descricao) VALUES ("Diretriz A", "Propor política pública intersetorial para a promoção da Saúde do Trabalhador, conforme Constituição Federal");
		INSERT INTO diretrizes (nome_diretriz, descricao) VALUES ("Diretriz B", "Elaborar propostas para aumentar a potência do SUS nas suas atribuições em Saúde do Trabalhador, em particular da vigilância e da capacidade diagnóstica de agravos relacionados ao trabalho");
		INSERT INTO diretrizes (nome_diretriz, descricao) VALUES ("Diretriz C", "Elaborar propostas para aumentar efetividade da participação e controle social no SUS");
		INSERT INTO diretrizes (nome_diretriz, descricao) VALUES ("Diretriz Indefinida", "");

		CREATE TABLE grupos		 (
			id_chave_grupo INT AUTO_INCREMENT PRIMARY KEY,
			nome_grupo varchar(100),
			unique(nome_grupo)
		);

		INSERT INTO grupos (nome_grupo) VALUES ("Grupo 1"); 
		INSERT INTO grupos (nome_grupo) VALUES ("Grupo 2"); 
		INSERT INTO grupos (nome_grupo) VALUES ("Grupo 3"); 



		CREATE TABLE eixos_diretrizes (
				id_chave_eixo_diretriz INT AUTO_INCREMENT PRIMARY KEY,
				nome_eixo_diretriz VARCHAR(100) NOT NULL,
			descricao varchar(3500),
			id_eixo int,
			id_diretriz int,
			unique(nome_eixo_diretriz),
			unique(id_eixo, id_diretriz),
			FOREIGN KEY (id_eixo) REFERENCES eixos(id_chave_eixo),
			FOREIGN KEY (id_diretriz) REFERENCES diretrizes(id_chave_diretriz)
		);


		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("I-A", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema I"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz A"));
		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("I-B", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema I"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz B"));
		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("I-C", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema I"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz C"));

		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("II-A", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema II"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz A"));
		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("II-B", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema II"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz B"));
		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("II-C", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema II"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz C"));

		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("III-A", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema III"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz A"));
		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("III-B", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema III"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz B"));
		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("III-C", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema III"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz C"));

		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("IV-A", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema IV"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz A"));
		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("IV-B", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema IV"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz B"));
		INSERT INTO eixos_diretrizes (nome_eixo_diretriz, descricao, id_eixo, id_diretriz) VALUES ("IV-C", "", (SELECT id_chave_eixo FROM eixos WHERE nome_eixo = "Tema IV"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz C"));

		CREATE TABLE grupos_diretrizes (
				id_chave_grupo_diretriz INT AUTO_INCREMENT PRIMARY KEY,
				nome_grupo_diretriz VARCHAR(100) NOT NULL,
			descricao varchar(3500),
			id_grupo int,
			id_diretriz int,
			unique(nome_grupo_diretriz),
			unique(id_grupo, id_diretriz),
			FOREIGN KEY (id_grupo) REFERENCES grupos(id_chave_grupo),
			FOREIGN KEY (id_diretriz) REFERENCES diretrizes(id_chave_diretriz)
		);


		INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("1-A", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 1"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz A"));
		#INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("1-B", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 1"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz B"));
		#INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("1-C", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 1"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz C"));

		#INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("2-A", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 2"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz A"));
		INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("2-B", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 2"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz B"));
		#INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("2-C", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 2"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz C"));

		#INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("3-A", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 3"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz A"));
		#INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("3-B", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 3"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz B"));
		INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("3-C", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 3"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz C"));

		CREATE TABLE propostas (
				id_chave_proposta INT AUTO_INCREMENT PRIMARY KEY,
				nome_proposta VARCHAR(100) NOT NULL,
			descricao varchar(750),
			id_grupo int,
			id_diretriz int,
			unique(nome_proposta),
			FOREIGN KEY (id_grupo) REFERENCES grupos(id_chave_grupo),
			FOREIGN KEY (id_diretriz) REFERENCES diretrizes(id_chave_diretriz)
		);
		CREATE TABLE versoes (
				id_chave_versao INT AUTO_INCREMENT PRIMARY KEY,
				nome_versao TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
			corpo_da_proposta varchar(750),
			id_proposta int,
			unique(nome_versao),
			FOREIGN KEY (id_proposta) REFERENCES propostas(id_chave_proposta)
		);


		DELIMITER //

DROP PROCEDURE IF EXISTS insere_proposta;

CREATE PROCEDURE insere_proposta( nome_grupo_param varchar(100), nome_proposta_param varchar(100), descricao_param varchar(750))
# insere uma proposta num grupo que tem apenas uma diretriz. Se tiver duas diretrizes constará como diretriz_indefinida, requerendo intervenção para corrigir isso

BEGIN

DECLARE conta_diretrizes INT;
DECLARE id_do_grupo INT;
DECLARE diretriz_unica INT;
DECLARE diretriz_indefinida INT;

    SELECT id_chave_diretriz INTO diretriz_indefinida
	FROM diretrizes as d
	WHERE d.nome_diretriz="Diretriz Indefinida";

    SELECT count(*) INTO conta_diretrizes
	FROM grupos_diretrizes as gd
	WHERE gd.id_grupo=(SELECT id_chave_grupo FROM grupos WHERE nome_grupo = nome_grupo_param);

	SELECT id_chave_grupo INTO id_do_grupo
	FROM grupos as g
	WHERE g.nome_grupo=nome_grupo_param;

    SELECT id_diretriz INTO diretriz_unica
	FROM grupos_diretrizes as gd
	WHERE gd.id_grupo=id_do_grupo LIMIT 1;


	# SELECT diretriz_indefinida;
	# SELECT conta_diretrizes;

	IF conta_diretrizes = 1 THEN
		INSERT INTO propostas (nome_proposta, descricao, id_grupo, id_diretriz) VALUES (nome_proposta_param, descricao_param, id_do_grupo, diretriz_unica); 
		
	ELSE
		INSERT INTO propostas (nome_proposta, descricao, id_grupo, id_diretriz) VALUES (nome_proposta_param, descricao_param, id_do_grupo, diretriz_indefinida); 
	END IF;
    INSERT INTO versoes (corpo_da_proposta, id_proposta) VALUES (descricao_param, LAST_INSERT_ID());
END //

DROP PROCEDURE IF EXISTS mostra_ultimas_versoes_das_propostas_do_grupo;

CREATE PROCEDURE mostra_ultimas_versoes_das_propostas_do_grupo(nome_grupo_param varchar(100))
BEGIN


		SELECT 
				substring_index(group_concat(t.nome_proposta order by t.nome_versao desc separator "@#$"),"@#$",1) as nome_proposta, 
				substring_index(group_concat(t.nome_grupo order by t.nome_versao desc separator "@#$"),"@#$",1) as nome_grupo, 
				substring_index(group_concat(t.nome_diretriz order by t.nome_versao desc separator "@#$"),"@#$",1) as nome_diretriz, 
				substring_index(group_concat(t.nome_versao order by t.nome_versao desc separator "@#$"),"@#$",1) as nome_versao, 
				substring_index(group_concat(t.corpo_da_proposta order by t.nome_versao desc separator "@#$"),"@#$",1) as ultima_versao, 
				substring_index(group_concat(t.id_proposta order by t.nome_versao desc separator "@#$"),"@#$",1) as id_proposta
		from 
			   (
			   		SELECT 
						nome_proposta, 
						nome_grupo, 
						nome_diretriz, 
						nome_versao, 
						corpo_da_proposta,
						v.id_proposta
					from 
						versoes as v, 
						propostas as p, 
						grupos, 
						diretrizes 
					where 
						v.id_proposta = id_chave_proposta and 
						p.id_grupo= id_chave_grupo and 
						p.id_diretriz = id_chave_diretriz and 
						nome_grupo = nome_grupo_param
			   ) as t
		group by t.id_proposta
		;
END //


DROP PROCEDURE IF EXISTS mostra_primeiras_versoes_das_propostas_do_grupo;

CREATE PROCEDURE mostra_primeiras_versoes_das_propostas_do_grupo(nome_grupo_param varchar(100))
BEGIN

		SELECT 
				substring_index(group_concat(t.nome_proposta order by t.nome_versao asc separator "@#$"),"@#$",1) as nome_proposta, 
				substring_index(group_concat(t.nome_grupo order by t.nome_versao asc separator "@#$"),"@#$",1) as nome_grupo, 
				substring_index(group_concat(t.nome_diretriz order by t.nome_versao asc separator "@#$"),"@#$",1) as nome_diretriz, 
				substring_index(group_concat(t.nome_versao order by t.nome_versao asc separator "@#$"),"@#$",1) as nome_versao, 
				substring_index(group_concat(t.corpo_da_proposta order by t.nome_versao asc separator "@#$"),"@#$",1) as primeira_versao, 
				substring_index(group_concat(t.id_proposta order by t.nome_versao asc separator "@#$"),"@#$",1) as id_proposta
		from 
			   (
			   		SELECT 
						nome_proposta, 
						nome_grupo, 
						nome_diretriz, 
						nome_versao, 
						corpo_da_proposta,
						v.id_proposta
					from 
						versoes as v, 
						propostas as p, 
						grupos, 
						diretrizes 
					where 
						v.id_proposta = id_chave_proposta and 
						p.id_grupo= id_chave_grupo and 
						p.id_diretriz = id_chave_diretriz and 
						nome_grupo = nome_grupo_param
			   ) as t
		group by t.id_proposta
		;
END //



DROP PROCEDURE IF EXISTS mostra_ultimas_versoes_de_todas_propostas_todos_grupos;

CREATE PROCEDURE mostra_ultimas_versoes_de_todas_propostas_todos_grupos()
BEGIN

SELECT 
	substring_index(group_concat(nome_grupo order by nome_versao desc separator "@#$"),"@#$",1) as nome_grupo, 
	substring_index(group_concat(nome_diretriz order by nome_versao desc separator "@#$"),"@#$",1) as nome_diretriz, 
	substring_index(group_concat(nome_proposta order by nome_versao desc separator "@#$"),"@#$",1) as nome_proposta, 
	substring_index(group_concat(nome_versao order by nome_versao desc separator "@#$"),"@#$",1) as nome_versao, 
	substring_index(group_concat(corpo_da_proposta order by nome_versao desc separator "@#$"),"@#$",1) as ultima_versao  
from 
	versoes as v, 
	propostas as p, 
	grupos as g, 
	diretrizes as d 
where 
	v.id_proposta = p.id_chave_proposta and 
	p.id_grupo = id_chave_grupo and 
	p.id_diretriz=id_chave_diretriz
group by 
	v.id_proposta;

END //


DROP PROCEDURE IF EXISTS altera_propostas;

CREATE PROCEDURE altera_propostas(id_proposta_param int, descricao_param varchar(750))
BEGIN

DECLARE conta_propostas INT;

SELECT count(*) INTO conta_propostas
    FROM propostas as p
    WHERE p.id_chave_proposta=id_proposta_param;

	IF conta_propostas = 1 THEN
		INSERT INTO versoes (corpo_da_proposta, id_proposta) VALUES (descricao_param, id_proposta_param);
	ELSE
		SELECT "Você está tentando alterar uma proposta inexistente ou tem mais de uma proposta com o mesmo identificador";
	END IF;

END //


DELIMITER ;

CALL insere_proposta("Grupo 1", "Proposta 1", "teste");
CALL insere_proposta("Grupo 1", "Proposta 4", "teste4");
CALL insere_proposta("Grupo 2", "Proposta 2", "teste2");
CALL insere_proposta("Grupo 3", "Proposta 3", "teste3");


#select * from propostas;
#select "-----";

CALL mostra_ultimas_versoes_das_propostas_do_grupo("Grupo 1");

#select * FROM versoes;

CALL altera_propostas(1, "mudanca");
CALL altera_propostas(1, "mudanca2");

#select * FROM versoes;
CALL mostra_ultimas_versoes_das_propostas_do_grupo("Grupo 1");
#select "ultimas";
CALL mostra_primeiras_versoes_das_propostas_do_grupo("Grupo 1");

CALL mostra_ultimas_versoes_de_todas_propostas_todos_grupos();

select nome_grupo, group_concat(nome_diretriz order by id_diretriz) from grupos, diretrizes, grupos_diretrizes where id_grupo=id_chave_grupo and id_diretriz=id_chave_diretriz group by nome_grupo;
select "-----";
select nome_eixo, group_concat(nome_diretriz order by id_diretriz) from eixos, diretrizes, eixos_diretrizes where id_eixo=id_chave_eixo and id_diretriz=id_chave_diretriz group by nome_eixo;

