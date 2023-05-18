start transaction;

DROP TABLE IF EXISTS versoes;
DROP TABLE IF EXISTS propostas;
DROP TABLE IF EXISTS grupos_diretrizes;
DROP TABLE IF EXISTS eixos_diretrizes;
DROP TABLE IF EXISTS diretrizes;
DROP TABLE IF EXISTS eixos;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS participantes_papeis;
DROP TABLE IF EXISTS participantes;
DROP TABLE IF EXISTS transicoes_de_status;
DROP TABLE IF EXISTS grupos;
DROP TABLE IF EXISTS autorizacoes;
DROP TABLE IF EXISTS papeis;
DROP TABLE IF EXISTS tipos_de_participacoes;
DROP TABLE IF EXISTS tipos_de_status;
DROP TABLE IF EXISTS paineis_de_interface;

		CREATE TABLE paineis_de_interface (
			id_chave_painel_de_interface INT AUTO_INCREMENT PRIMARY KEY,
			nome_painel_de_interface VARCHAR(100),
			UNIQUE(nome_painel_de_interface)
		);
		INSERT INTO paineis_de_interface (nome_painel_de_interface) VALUES ("insercao_proposta_votacao_inscricao_destaque");
		INSERT INTO paineis_de_interface (nome_painel_de_interface) VALUES ("meu_grupo");
		INSERT INTO paineis_de_interface (nome_painel_de_interface) VALUES ("todos_grupos");
		INSERT INTO paineis_de_interface (nome_painel_de_interface) VALUES ("mudanca_status");
		INSERT INTO paineis_de_interface (nome_painel_de_interface) VALUES ("insercao_participante");

		CREATE TABLE tipos_de_status (
			id_chave_tipo_de_status INT AUTO_INCREMENT PRIMARY KEY,
			nome_tipo_de_status VARCHAR(100),
			UNIQUE(nome_tipo_de_status)
		);

		INSERT INTO tipos_de_status (nome_tipo_de_status) VALUES ("submissão de proposta");
		INSERT INTO tipos_de_status (nome_tipo_de_status) VALUES ("em debate");
		INSERT INTO tipos_de_status (nome_tipo_de_status) VALUES ("leitura das propostas");
		INSERT INTO tipos_de_status (nome_tipo_de_status) VALUES ("destaques para propostas");
		INSERT INTO tipos_de_status (nome_tipo_de_status) VALUES ("inscricoes para fala");
		INSERT INTO tipos_de_status (nome_tipo_de_status) VALUES ("votação das propostas nos GTs");
		INSERT INTO tipos_de_status (nome_tipo_de_status) VALUES ("votação das propostas nas Plenárias");

# o sistema só pode estar num estado de cada vez, portanto o estado atual é o último registrado na tabela abaixo
# as transicoes sao registradas por grupo

		CREATE TABLE tipos_de_participacoes (
			id_chave_tipo_de_participacao INT AUTO_INCREMENT PRIMARY KEY,
			nome_tipo_de_participacao VARCHAR(100),
			UNIQUE(nome_tipo_de_participacao)
		);

		INSERT INTO tipos_de_participacoes (nome_tipo_de_participacao) VALUES ("presencial");
		INSERT INTO tipos_de_participacoes (nome_tipo_de_participacao) VALUES ("remota");

		CREATE TABLE papeis (
			id_chave_papel INT AUTO_INCREMENT PRIMARY KEY,
			nome_papel VARCHAR(100),
			UNIQUE(nome_papel)
		);
		INSERT INTO papeis (nome_papel) VALUES ("coordenador(a)");
		INSERT INTO papeis (nome_papel) VALUES ("relator(a)");
		INSERT INTO papeis (nome_papel) VALUES ("participante");

		CREATE TABLE autorizacoes (
			id_chave_autorizacao INT AUTO_INCREMENT PRIMARY KEY,
			nome_autorizacao VARCHAR(100),
			id_papel INT,
			id_paineis_de_interface INT,
			FOREIGN KEY (id_papel) REFERENCES papeis(id_chave_papel),
			FOREIGN KEY (id_paineis_de_interface) REFERENCES paineis_de_interface(id_chave_painel_de_interface),
			UNIQUE(nome_autorizacao)
		);
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Coordenador(a) pode votar, inscrever, fazer destaque e inserir proposta",(SELECT id_chave_papel FROM papeis where nome_papel="coordenador(a)"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "insercao_proposta_votacao_inscricao_destaque"));
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Coordenador(a) pode mudar o status da reunião",(SELECT id_chave_papel FROM papeis where nome_papel="coordenador(a)"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "mudanca_status"));
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Coordenador(a) tem acesso a todos os grupos",(SELECT id_chave_papel FROM papeis where nome_papel="coordenador(a)"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "todos_grupos"));
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Coordenador(a) pode inserir participante",(SELECT id_chave_papel FROM papeis where nome_papel="coordenador(a)"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "insercao_participante"));

		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Relator(a) pode votar, inscrever, fazer destaque e inserir proposta",(SELECT id_chave_papel FROM papeis where nome_papel="relator(a)"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "insercao_proposta_votacao_inscricao_destaque"));
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Relator(a) pode mudar o status da reunião",(SELECT id_chave_papel FROM papeis where nome_papel="relator(a)"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "mudanca_status"));
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Relator(a) tem acesso a todos os grupos",(SELECT id_chave_papel FROM papeis where nome_papel="relator(a)"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "todos_grupos"));
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Relator(a) pode inserir participante",(SELECT id_chave_papel FROM papeis where nome_papel="relator(a)"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "insercao_participante"));
		
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Participante pode votar, inscrever, fazer destaque e inserir proposta",(SELECT id_chave_papel FROM papeis where nome_papel="participante"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "insercao_proposta_votacao_inscricao_destaque"));
		INSERT INTO autorizacoes (nome_autorizacao, id_papel, id_paineis_de_interface) VALUES ("Participante tem acesso apenas a seu próprio grupo",(SELECT id_chave_papel FROM papeis where nome_papel="participante"),(SELECT id_chave_painel_de_interface FROM paineis_de_interface WHERE nome_painel_de_interface = "meu_grupo"));


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
			id_tipo_de_participacao int,
			FOREIGN KEY (id_tipo_de_participacao) REFERENCES tipos_de_participacoes(id_chave_tipo_de_participacao),
			unique(nome_grupo)
		);

		CREATE TABLE transicoes_de_status (
			id_chave_transicao_de_status INT AUTO_INCREMENT PRIMARY KEY,
			nome_transicao_de_status VARCHAR(100),
			momento_da_transicao TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
			id_tipo_de_status INT,
			id_grupo INT,
			FOREIGN KEY (id_grupo) REFERENCES grupos(id_chave_grupo),
			FOREIGN KEY (id_tipo_de_status) REFERENCES tipos_de_status(id_chave_tipo_de_status),
			UNIQUE(nome_transicao_de_status)
		);


		CREATE TABLE participantes (
			id_chave_participante INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
			nome_participante VARCHAR(100),
			id_grupo INT,
			id_grupo_afinidade INT,
			sequencial INT,
            ordem_de_insercao TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6),
			cpf VARCHAR(300),
			FOREIGN KEY (id_grupo) REFERENCES grupos(id_chave_grupo),
			FOREIGN KEY (id_grupo_afinidade) REFERENCES grupos(id_chave_grupo),
			UNIQUE(nome_participante)
		);

		CREATE TABLE users (
			id_chave_user INT AUTO_INCREMENT PRIMARY KEY,
			nome_user VARCHAR(100),
			senha VARCHAR(300),
			id_participante INT,
			FOREIGN KEY (id_participante) REFERENCES participantes(id_chave_participante),
			UNIQUE(nome_user)
		);

		INSERT INTO users (nome_user, senha) VALUES ("pedro","$2y$10$EECgzrOjZDADL35JU9kLaOmiOtSNuPP1FP9rlQlmheGuLpyr7qHRu");
		INSERT INTO users (nome_user, senha) VALUES ("victor","$2y$10$EECgzrOjZDADL35JU9kLaOmiOtSNuPP1FP9rlQlmheGuLpyr7qHRu");

		CREATE TABLE participantes_papeis (
				id_chave_participante_papel INT AUTO_INCREMENT PRIMARY KEY,
				nome_participante_papel VARCHAR(500),
			id_papel int,
			id_participante int,
			unique(nome_participante_papel),
			unique(id_papel, id_participante),
			FOREIGN KEY (id_papel) REFERENCES papeis(id_chave_papel),
			FOREIGN KEY (id_participante) REFERENCES participantes(id_chave_participante)
		);

		INSERT INTO grupos (nome_grupo, id_tipo_de_participacao) VALUES ("Grupo 1", (SELECT id_chave_tipo_de_participacao FROM tipos_de_participacoes WHERE nome_tipo_de_participacao = "presencial")); 
		INSERT INTO grupos (nome_grupo, id_tipo_de_participacao) VALUES ("Grupo 2", (SELECT id_chave_tipo_de_participacao FROM tipos_de_participacoes WHERE nome_tipo_de_participacao = "presencial")); 
		INSERT INTO grupos (nome_grupo, id_tipo_de_participacao) VALUES ("Grupo 3", (SELECT id_chave_tipo_de_participacao FROM tipos_de_participacoes WHERE nome_tipo_de_participacao = "presencial")); 
		INSERT INTO grupos (nome_grupo, id_tipo_de_participacao) VALUES ("Grupo 4", (SELECT id_chave_tipo_de_participacao FROM tipos_de_participacoes WHERE nome_tipo_de_participacao = "remota")); 
		INSERT INTO grupos (nome_grupo, id_tipo_de_participacao) VALUES ("Grupo 5", (SELECT id_chave_tipo_de_participacao FROM tipos_de_participacoes WHERE nome_tipo_de_participacao = "remota")); 
		INSERT INTO grupos (nome_grupo, id_tipo_de_participacao) VALUES ("Grupo 6", (SELECT id_chave_tipo_de_participacao FROM tipos_de_participacoes WHERE nome_tipo_de_participacao = "remota")); 



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


		INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("4-A", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 4"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz A"));
		INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("5-B", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 5"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz B"));
		INSERT INTO grupos_diretrizes (nome_grupo_diretriz, descricao, id_grupo, id_diretriz) VALUES ("6-C", "", (SELECT id_chave_grupo FROM grupos WHERE nome_grupo = "Grupo 6"), (SELECT id_chave_diretriz FROM diretrizes WHERE nome_diretriz = "Diretriz C"));


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

DROP PROCEDURE IF EXISTS distribui_grupos;

CREATE PROCEDURE distribui_grupos()
BEGIN


DECLARE n_grupos INT;
DECLARE indice_grupos INT;
DECLARE n_participantes INT;
DECLARE indice_participantes INT;
DECLARE chave_do_grupo INT;

# preciso de uma coluna ordenada sequencialemente para poder percorrer o update um a um distribuindo os grupos
SET @sequencial=0;
update participantes set sequencial =  (@sequencial:=@sequencial + 1) ORDER BY ordem_de_insercao;

SET indice_participantes=0;

SELECT COUNT(*) INTO n_grupos FROM grupos;
SELECT COUNT(*) INTO n_participantes FROM participantes;



WHILE indice_participantes < n_participantes DO
	SET indice_grupos=0;
	WHILE indice_grupos < n_grupos DO
		SELECT id_chave_grupo INTO chave_do_grupo FROM grupos LIMIT 1 OFFSET indice_grupos;
		UPDATE participantes SET id_grupo = chave_do_grupo WHERE sequencial = indice_participantes+1;
		SET indice_grupos = indice_grupos + 1;
		SET indice_participantes= indice_participantes + 1;
	END WHILE;
END WHILE;

END //


DELIMITER ;

CALL insere_proposta("Grupo 1", "Proposta 1", "Financiar melhor o SUS");
CALL insere_proposta("Grupo 1", "Proposta 2", "Tornar o SUS mais amplo");
CALL insere_proposta("Grupo 2", "Proposta 3", "Incluir uma pauta multi-setorial no SUS");
CALL insere_proposta("Grupo 3", "Proposta 4", "Rever as medidas privatizantes do SUS no que se refere à saúde do trabalhador");
CALL insere_proposta("Grupo 4", "Proposta 5", "Pensar formas de integrar ações do MTE com o MS");
CALL insere_proposta("Grupo 5", "Proposta 6", "Tornar a pauta de segurança do trabalho presente no dia a dia do SUS");
CALL insere_proposta("Grupo 6", "Proposta 7", "Melhor formas de notificação de acidentes de trabalho");


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


INSERT INTO participantes (nome_participante, cpf) VALUES ("Alice Fernandes","01234567890");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Amanda Rodrigues","78901234567");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Amanda Santos","45678901234");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Ana Clara Castro","90123456789");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Ana Clara Lima","12345678901");
INSERT INTO participantes (nome_participante, cpf) VALUES ("André Ribeiro","67890123456");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Beatriz Oliveira","23456789012");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Bruno Martins","12345678901");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Bruno Oliveira","01234567890");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Camila Castro","89012345678");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Carolina Lima","12345678901");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Carolina Souza","90123456789");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Daniel Lima","12345678901");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Diego Santos","23456789012");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Eduardo Lima","89012345678");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Enzo Ribeiro","45678901234");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Enzo Souza","90123456789");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Felipe Mendes","67890123456");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Felipe Silva","23456789012");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Gabriel Alves","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Gabriel Mendes","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Gabriel Pereira","78901234567");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Gabriel Santos","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Giovanna Costa","90123456789");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Giovanna Gonçalves","78901234567");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Giovanna Silva","78901234567");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Guilherme Barbosa","45678901234");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Guilherme Lima","34567890123");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Gustavo Almeida","78901234567");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Gustavo Alves","34567890123");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Helena Lima","34567890123");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Helena Oliveira","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Henrique Castro","34567890123");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Isabela Almeida","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Isabela Ferreira","23456789012");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Isabella Santos","90123456789");
INSERT INTO participantes (nome_participante, cpf) VALUES ("João Barbosa","78901234567");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Júlia Almeida","34567890123");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Júlia Oliveira","12345678901");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Larissa Fernandes","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Laura Carvalho","78901234567");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Laura Rodrigues","45678901234");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Leonardo Castro","67890123456");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Leonardo Martins","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Luana Oliveira","23456789012");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Lucas Ferreira","89012345678");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Lucas Silva","01234567890");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Luiza Carvalho","45678901234");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Luiza Silva","45678901234");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Manuela Costa","98765432109");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Manuela Pereira","34567890123");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Mariana Gonçalves","34567890123");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Mariana Lima","78901234567");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Mariana Silva","01234567890");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Maria Oliveira","45678901234");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Matheus Carvalho","34567890123");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Matheus Pereira","67890123456");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Matheus Santos","01234567890");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Melissa Santos","45678901234");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Nicolas Almeida","67890123456");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Nicolas Ferreira","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Pedro Barbosa","98765432109");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Pedro Rodrigues","90123456789");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Rafael Costa","23456789012");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Rafael Oliveira","89012345678");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Rafael Silva","01234567890");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Samuel Castro","23456789012");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Samuel Pereira","90123456789");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Sophia Costa","56789012345");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Thiago Ribeiro","89012345678");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Valentina Rodrigues","90123456789");
INSERT INTO participantes (nome_participante, cpf) VALUES ("Victor Rodrigues","01234567890");


INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Alice Fernandes-participante", (SELECT id_chave_participante from participantes where nome_participante = "Alice Fernandes"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Amanda Rodrigues-participante", (SELECT id_chave_participante from participantes where nome_participante = "Amanda Rodrigues"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Amanda Santos-participante", (SELECT id_chave_participante from participantes where nome_participante = "Amanda Santos"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Ana Clara Castro-participante", (SELECT id_chave_participante from participantes where nome_participante = "Ana Clara Castro"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Ana Clara Lima-participante", (SELECT id_chave_participante from participantes where nome_participante = "Ana Clara Lima"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("André Ribeiro-participante", (SELECT id_chave_participante from participantes where nome_participante = "André Ribeiro"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Beatriz Oliveira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Beatriz Oliveira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Bruno Martins-participante", (SELECT id_chave_participante from participantes where nome_participante = "Bruno Martins"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Bruno Oliveira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Bruno Oliveira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Camila Castro-participante", (SELECT id_chave_participante from participantes where nome_participante = "Camila Castro"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Carolina Lima-participante", (SELECT id_chave_participante from participantes where nome_participante = "Carolina Lima"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Carolina Souza-participante", (SELECT id_chave_participante from participantes where nome_participante = "Carolina Souza"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Daniel Lima-relator(a)", (SELECT id_chave_participante from participantes where nome_participante = "Daniel Lima"), (SELECT id_chave_papel from papeis where nome_papel = "relator(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Diego Santos-coordenador(a)", (SELECT id_chave_participante from participantes where nome_participante = "Diego Santos"), (SELECT id_chave_papel from papeis where nome_papel = "coordenador(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Eduardo Lima-coordenador(a)", (SELECT id_chave_participante from participantes where nome_participante = "Eduardo Lima"), (SELECT id_chave_papel from papeis where nome_papel = "coordenador(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Enzo Ribeiro-participante", (SELECT id_chave_participante from participantes where nome_participante = "Enzo Ribeiro"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Enzo Souza-coordenador(a)", (SELECT id_chave_participante from participantes where nome_participante = "Enzo Souza"), (SELECT id_chave_papel from papeis where nome_papel = "coordenador(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Felipe Mendes-participante", (SELECT id_chave_participante from participantes where nome_participante = "Felipe Mendes"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Felipe Silva-participante", (SELECT id_chave_participante from participantes where nome_participante = "Felipe Silva"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Gabriel Alves-coordenador(a)", (SELECT id_chave_participante from participantes where nome_participante = "Gabriel Alves"), (SELECT id_chave_papel from papeis where nome_papel = "coordenador(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Gabriel Mendes-participante", (SELECT id_chave_participante from participantes where nome_participante = "Gabriel Mendes"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Gabriel Pereira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Gabriel Pereira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Gabriel Santos-participante", (SELECT id_chave_participante from participantes where nome_participante = "Gabriel Santos"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Giovanna Costa-participante", (SELECT id_chave_participante from participantes where nome_participante = "Giovanna Costa"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Giovanna Gonçalves-participante", (SELECT id_chave_participante from participantes where nome_participante = "Giovanna Gonçalves"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Giovanna Silva-participante", (SELECT id_chave_participante from participantes where nome_participante = "Giovanna Silva"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Guilherme Barbosa-participante", (SELECT id_chave_participante from participantes where nome_participante = "Guilherme Barbosa"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Guilherme Lima-participante", (SELECT id_chave_participante from participantes where nome_participante = "Guilherme Lima"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Gustavo Almeida-participante", (SELECT id_chave_participante from participantes where nome_participante = "Gustavo Almeida"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Gustavo Alves-participante", (SELECT id_chave_participante from participantes where nome_participante = "Gustavo Alves"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Helena Lima-relator(a)", (SELECT id_chave_participante from participantes where nome_participante = "Helena Lima"), (SELECT id_chave_papel from papeis where nome_papel = "relator(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Helena Oliveira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Helena Oliveira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Henrique Castro-participante", (SELECT id_chave_participante from participantes where nome_participante = "Henrique Castro"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Isabela Almeida-relator(a)", (SELECT id_chave_participante from participantes where nome_participante = "Isabela Almeida"), (SELECT id_chave_papel from papeis where nome_papel = "relator(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Isabela Ferreira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Isabela Ferreira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Isabella Santos-participante", (SELECT id_chave_participante from participantes where nome_participante = "Isabella Santos"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("João Barbosa-participante", (SELECT id_chave_participante from participantes where nome_participante = "João Barbosa"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Júlia Almeida-participante", (SELECT id_chave_participante from participantes where nome_participante = "Júlia Almeida"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Júlia Oliveira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Júlia Oliveira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Larissa Fernandes-participante", (SELECT id_chave_participante from participantes where nome_participante = "Larissa Fernandes"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Laura Carvalho-participante", (SELECT id_chave_participante from participantes where nome_participante = "Laura Carvalho"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Laura Rodrigues-participante", (SELECT id_chave_participante from participantes where nome_participante = "Laura Rodrigues"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Leonardo Castro-participante", (SELECT id_chave_participante from participantes where nome_participante = "Leonardo Castro"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Leonardo Martins-coordenador(a)", (SELECT id_chave_participante from participantes where nome_participante = "Leonardo Martins"), (SELECT id_chave_papel from papeis where nome_papel = "coordenador(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Luana Oliveira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Luana Oliveira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Lucas Ferreira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Lucas Ferreira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Lucas Silva-participante", (SELECT id_chave_participante from participantes where nome_participante = "Lucas Silva"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Luiza Carvalho-relator(a)", (SELECT id_chave_participante from participantes where nome_participante = "Luiza Carvalho"), (SELECT id_chave_papel from papeis where nome_papel = "relator(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Luiza Silva-participante", (SELECT id_chave_participante from participantes where nome_participante = "Luiza Silva"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Manuela Costa-participante", (SELECT id_chave_participante from participantes where nome_participante = "Manuela Costa"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Manuela Pereira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Manuela Pereira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Mariana Gonçalves-participante", (SELECT id_chave_participante from participantes where nome_participante = "Mariana Gonçalves"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Mariana Lima-participante", (SELECT id_chave_participante from participantes where nome_participante = "Mariana Lima"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Mariana Silva-participante", (SELECT id_chave_participante from participantes where nome_participante = "Mariana Silva"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Maria Oliveira-relator(a)", (SELECT id_chave_participante from participantes where nome_participante = "Maria Oliveira"), (SELECT id_chave_papel from papeis where nome_papel = "relator(a)"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Matheus Carvalho-participante", (SELECT id_chave_participante from participantes where nome_participante = "Matheus Carvalho"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Matheus Pereira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Matheus Pereira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Matheus Santos-participante", (SELECT id_chave_participante from participantes where nome_participante = "Matheus Santos"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Melissa Santos-participante", (SELECT id_chave_participante from participantes where nome_participante = "Melissa Santos"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Nicolas Almeida-participante", (SELECT id_chave_participante from participantes where nome_participante = "Nicolas Almeida"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Nicolas Ferreira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Nicolas Ferreira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Pedro Barbosa-participante", (SELECT id_chave_participante from participantes where nome_participante = "Pedro Barbosa"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Pedro Rodrigues-participante", (SELECT id_chave_participante from participantes where nome_participante = "Pedro Rodrigues"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Rafael Costa-participante", (SELECT id_chave_participante from participantes where nome_participante = "Rafael Costa"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Rafael Oliveira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Rafael Oliveira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Rafael Silva-participante", (SELECT id_chave_participante from participantes where nome_participante = "Rafael Silva"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Samuel Castro-participante", (SELECT id_chave_participante from participantes where nome_participante = "Samuel Castro"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Samuel Pereira-participante", (SELECT id_chave_participante from participantes where nome_participante = "Samuel Pereira"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Sophia Costa-participante", (SELECT id_chave_participante from participantes where nome_participante = "Sophia Costa"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Thiago Ribeiro-participante", (SELECT id_chave_participante from participantes where nome_participante = "Thiago Ribeiro"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Valentina Rodrigues-participante", (SELECT id_chave_participante from participantes where nome_participante = "Valentina Rodrigues"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES ("Victor Rodrigues-participante", (SELECT id_chave_participante from participantes where nome_participante = "Victor Rodrigues"), (SELECT id_chave_papel from papeis where nome_papel = "participante"));
commit;
