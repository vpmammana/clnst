<?php

if(isset($_GET["nome_grupo_param"])){
  $nome_grupo_param= $_GET["nome_grupo_param"];
} else $nome_grupo_param = "Grupo 3";

if(isset($_GET["participante"])){
  $participante= $_GET["participante"];
} else $participante = "Dummy";

include "identify.php.cripto";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}

$campos=[];

$sql = '
SELECT
    substring_index(group_concat(nome_grupo order by nome_versao desc separator "@#$"),"@#$",1) as nome_grupo,
    substring_index(group_concat(nome_diretriz order by nome_versao desc separator "@#$"),"@#$",1) as nome_diretriz,
    substring_index(group_concat(d.descricao order by nome_versao desc separator "@#$"),"@#$",1) as descricao_diretriz,
    substring_index(group_concat(nome_proposta order by nome_versao desc separator "@#$"),"@#$",1) as nome_proposta,
    substring_index(group_concat(nome_versao order by nome_versao desc separator "@#$"),"@#$",1) as nome_versao,
    substring_index(group_concat(corpo_da_proposta order by nome_versao desc separator "@#$"),"@#$",1) as ultima_versao,
    substring_index(group_concat(nome_tipo_de_participacao order by nome_versao desc separator "@#$"),"@#$",1) as nome_tipo_de_participacao
from
    versoes as v,
    propostas as p,
    grupos as g,
    diretrizes as d,
	tipos_de_participacoes tp
where
    v.id_proposta = p.id_chave_proposta and
    p.id_grupo = id_chave_grupo and
	tp.id_chave_tipo_de_participacao = g.id_tipo_de_participacao and
    p.id_diretriz=id_chave_diretriz
group by
    v.id_proposta;
';

$result = $conn->query($sql);

$numero_grupos = 0;
$velho_grupo="";

if ($result->num_rows > 0) {
    // Loop para exibir os dados retornados
	$indice_conta=0;
    while ($row = $result->fetch_assoc()) {
		$nome_grupo = $row["nome_grupo"];
		if ($nome_grupo == $velho_grupo){} else {$numero_grupos++;}
		$campos[$indice_conta][]=$row["nome_grupo"];
		$campos[$indice_conta][]=$row["nome_diretriz"];
		$campos[$indice_conta][]=$row["nome_proposta"];
		$campos[$indice_conta][]=$row["nome_versao"];
		$campos[$indice_conta][]=$row["ultima_versao"];
		$campos[$indice_conta][]=$row["descricao_diretriz"];
		$campos[$indice_conta][]=$row["nome_tipo_de_participacao"];
		$indice_conta++;	
		$velho_grupo = $nome_grupo;
    }
} else {
    echo "Nenhum resultado encontrado.";
}

echo '
<!DOCTYPE html>
<html>
	<head>
		<title>
PHP
		</title>
	</head>
<style>

body {
  background-image: linear-gradient(to bottom, #222222, #000000);
}

.entrada_de_dados {
  position: absolute;
  top: 61%;
  width: 95%;
  height: 35%;
  background-color: darkgreen;
  border-radius: 3%/10%;
  margin: auto;
  left: 50%;
  transform: translateX(-50%);
  padding: 1%;
}

.carousel {
  position: absolute;
  top: 0%;
  left: 0%;
  width: 100%;
  height: 60%;
  border: 3px solid blue;
  overflow-x: scroll;
  transition: transform 0.5s ease;
  scroll-behavior: smooth;
  background-color: lightgray;
}

.carousel-items {
  display: flex;
  width: '.round($numero_grupos*100).'%;
  height: 99.5%;
  transition: transform 0.5s ease;
  border: 3px solid black;
  justify-content: space-between;
}

.carousel-item {
  width: '.round(90/$numero_grupos).'%; 
  height: 98%;
  padding: 0.1%;
  box-sizing: border-box;
  border: 3px solid darkgray;
  flex-grow: 1;
  transition: transform 0.5s ease;
  margin: 0 1%;
  border-radius: 2%/6%;
  background-color: gray;
  transform: translateZ(0);
  transform-style: preserve-3d;
}

.proposta{
	border-bottom: 12px solid gray;
	background-color: black;
	color: white;
	padding: 1%;
	font-size:2rem;
}

.carousel-control {
  position: absolute;
  top: 55%;
  transform: translateY(-50%);
  background-color: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  padding: 10px;
  cursor: pointer;
  font-size: 4rem;
}

.carousel-control.prev {
  left: 0%;
}
.carousel-control.next {
  right: 0%;
}

.carousel-item.active {
  display: block;
}

.titulo {
	font-size: 2rem;
	font-weight: bold;
}

.subtitulo {
	font-size: 1.5rem;
	color: blue;
}


.diretriz {
	font-size: 1.6rem;
	font-weight: bold;
}

.tabela_do_grupo {
	width: 100%;
	border-collapse: collapse;
}

.botoes {
  background-color: rgba(0, 0, 0, 0.9);
  color: white;
  border: none;
  padding: 10px;
  cursor: pointer;
  font-size: 2rem;
  display: block;
  margin: 0 auto;
}

.cell_centrada {
	text-align: center;
	vertical-align: middle;
}

</style>

<body>
<div class="entrada_de_dados">
<table class="tabela_do_grupo">
	<tr>
		<td class="cell_centrada">
			<button id="adiciona_proposta" class="botoes" onclick="">Nova Proposta +</button>
		</td>
		<td class="cell_centrada">
			<button id="Meu Grupo" class="botoes" onclick="va_pro_meu_grupo(nome_grupo_param)">Meu Grupo</button>
		</td>
		<td class="cell_centrada">
			<button id="adiciona_proposta2" class="botoes" onclick="">Nova Proposta</button>
		</td>
	</tr>
</table>
</div>
<div id="carrosel" class="carousel">
  <div id="tripa_carrosel" class="carousel-items">';

$velho_grupo = "";
$conta_grupos=0;
foreach ($campos as $chave=>$valor){

if ($velho_grupo != "" && $campos[$chave][0] != $velho_grupo){
echo '
</table>
</div>';
}

if ($velho_grupo == "" || $campos[$chave][0] != $velho_grupo){
echo '
    <div class="carousel-item active grupo" data-ordem="'.$conta_grupos.'" id="'.$campos[$chave][0].'">
	  <table class="tabela_do_grupo">
	  <tr>
      <td><b class="titulo">'.$campos[$chave][0].'<br></b><b class="subtitulo">(participação '.$campos[$chave][6].')</b></td>
	  <td><b class="diretriz">'.$campos[$chave][5].'</b></td>
	  </tr>';
	  $conta_grupos++;
}

echo '<tr><td class="proposta"><div>'.$campos[$chave][2].'<br>'.$campos[$chave][3].'</div></td>
<td class="proposta">'.$campos[$chave][4].'</td>
</tr>';

$velho_grupo = $campos[$chave][0]; // nome_grupo
}
echo '
  </table>
  </div>
  </div>
</div>

  <button id="tras" class="carousel-control prev" onclick="changeSlide(-1)">trás</button>
  <button id="frente" class="carousel-control next" onclick="changeSlide(1)">frente</button>

<script>

var numero_grupos = '.$numero_grupos.';
var nome_grupo_param = "'.$nome_grupo_param.'";

var carrosel       = document.getElementById("carrosel");
var tripa_carrosel = document.getElementById("tripa_carrosel");
var divs_do_carrosel = document.getElementsByClassName("carrosel_item");

var botao_tras = document.getElementById("tras");
var botao_frente = document.getElementById("frente");

var scroll_dos_grupos = [];
var lista_de_grupos = document.getElementsByClassName("grupo");
var largura_item = tripa_carrosel.getBoundingClientRect().width / numero_grupos;

botao_tras.style.top = carrosel.getBoundingClientRect().bottom; 

function inicializa_posicoes(){
	for (var i=0; i < lista_de_grupos.length; i++){
		var elemento = lista_de_grupos[i];
		elemento.setAttribute("data-scroll", i*largura_item);
	}

}

function changeSlide(indice){
	
	carrosel.scrollLeft = carrosel.scrollLeft - indice * largura_item;

}

function va_pro_meu_grupo(nome_grupo_param){
	carrosel.scrollLeft = document.getElementById(nome_grupo_param).getAttribute("data-scroll");
}


inicializa_posicoes();
va_pro_meu_grupo(nome_grupo_param);

</script>
</body>
</html>';
?>

