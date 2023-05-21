<?php

if(isset($_GET["nome_grupo_param"])){
  $nome_grupo_param= $_GET["nome_grupo_param"];
} else $nome_grupo_param = "Grupo 1";

include "identify.php.cripto";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}

$campos=[];

$sql ="
select
	id_tipo_de_status,
    nome_tipo_de_status,
	id_proposta
from
	transicoes_de_status as ts,
	tipos_de_status,
	grupos
where
    ts.id_grupo = id_chave_grupo and
	ts.id_tipo_de_status = id_chave_tipo_de_status and
	nome_grupo = '".$nome_grupo_param."'
	order by momento_da_transicao desc limit 1;";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
		$status = $row["nome_tipo_de_status"];
		$id_proposta = $row["id_proposta"];
		echo $status."@#$".$id_proposta;
    }
} else {
    echo "Nenhum resultado encontrado.";
}

?>
