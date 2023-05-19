<?php

if(isset($_GET["nome_grupo_param"])){
  $nome_grupo_param= $_GET["nome_grupo_param"];
} else $nome_grupo_param = "Grupo 1";

if(isset($_GET["status_param"])){
  $status_param= $_GET["status_param"];
} else $status_param = "NULL";

if(isset($_GET["proposta_param"])){
  $proposta_param= $_GET["proposta_param"];
} else $proposta_param = "NULL";



include "identify.php.cripto";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}

$campos=[];

$sql ="
insert into transicoes_de_status (nome_transicao_de_status, id_proposta, id_tipo_de_status, id_grupo) VALUES ('".$status_param."',".$proposta_param.", (SELECT id_chave_tipo_de_status FROM tipos_de_status WHERE nome_tipo_de_status = '".$status_param."'), (SELECT id_chave_grupo FROM grupos WHERE nome_grupo='".$nome_grupo_param."'));
";

if ($conn->query($sql) === TRUE) {
    echo "Inserção bem sucedida";
} else {
    echo "Erro na inserção: " . $conn->error;
}


?>
