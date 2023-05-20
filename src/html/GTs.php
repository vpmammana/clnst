<?php

if(isset($_GET["id_participante_param"])){
  $id_participante_param= $_GET["id_participante_param"];
} else $id_participante_param = "1";


include "identify.php.cripto";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Falha na conexão: " . $conn->connect_error);
}

$campos=[];

$sql_inicial ="
select
    id_chave_participante,
    nome_grupo,
    nome_participante,
    nome_papel,
    nome_autorizacao,
    nome_painel_de_interface
from
    grupos as g,
    participantes as p,
    papeis as pp,
    autorizacoes as a,
    paineis_de_interface as pi,
    participantes_papeis as pap
where
    p.id_grupo = id_chave_grupo and
    p.id_chave_participante=pap.id_participante and
    id_chave_papel=pap.id_papel and
    id_chave_papel=a.id_papel and
    a.id_painel_de_interface=id_chave_painel_de_interface and
    a.id_papel=id_chave_papel and
    a.id_papel=pap.id_papel and
    id_chave_participante = ".$id_participante_param."
    order by nome_grupo, nome_participante, nome_papel, nome_painel_de_interface;";

$result_inicial = $conn->query($sql_inicial);
if ($result_inicial->num_rows > 0) {
	$papeis="";
	$paineis="";
	$nome_grupo_param="";
	$nome_participante_param="";
// Loop para exibir os dados retornados
	$indice_conta=0;
    while ($row_inicial = $result_inicial->fetch_assoc()) {
		if (strpos($nome_grupo_param,$row_inicial["nome_grupo"])===false) {$nome_grupo_param =$nome_grupo_param.$row_inicial["nome_grupo"]." ";}
		if (strpos($nome_participante_param, $row_inicial["nome_participante"])===false){ $nome_participante_param = $nome_participante_param.$row_inicial["nome_participante"]." ";}
		if (strpos($papeis,$row_inicial["nome_papel"])===false) {$papeis=$papeis.$row_inicial["nome_papel"]." ";}
		if (strpos($paineis,$row_inicial["nome_painel_de_interface"])===false) {$paineis=$paineis.$row_inicial["nome_painel_de_interface"]." ";}
    }
} else {
    echo "Nenhum resultado encontrado.";
}

$nome_grupo_param = trim($nome_grupo_param);
$nome_participante_param = trim($nome_participante_param);
$papeis  = trim($papeis);
$paineis = trim($paineis);

// echo "(".$nome_grupo_param.")<br>";
// echo "(".$nome_participante_param.")<br>";
// echo "(".$papeis.")<br>";
// echo "(".$paineis.")";





$sql_transicao ="
select
	id_tipo_de_status,
    nome_tipo_de_status
from
	transicoes_de_status as ts,
	tipos_de_status,
	grupos
where
    ts.id_grupo = id_chave_grupo and
	ts.id_tipo_de_status = id_chave_tipo_de_status and
	nome_grupo = '".$nome_grupo_param."'
	order by momento_da_transicao desc limit 1;";

$result_transicao = $conn->query($sql_transicao);

if ($result_transicao->num_rows > 0) {
    while ($row_transicao = $result_transicao->fetch_assoc()) {
		$status_transicao = $row_transicao["nome_tipo_de_status"];
		//echo $status_transicao;
    }
} else {
    echo "Nenhum resultado encontrado.";
}




// exit();

$sql = '
SELECT
    substring_index(group_concat(nome_grupo order by nome_versao desc separator "@#$"),"@#$",1) as nome_grupo,
    substring_index(group_concat(nome_diretriz order by nome_versao desc separator "@#$"),"@#$",1) as nome_diretriz,
    substring_index(group_concat(d.descricao order by nome_versao desc separator "@#$"),"@#$",1) as descricao_diretriz,
    substring_index(group_concat(nome_proposta order by nome_versao desc separator "@#$"),"@#$",1) as nome_proposta,
    substring_index(group_concat(nome_versao order by nome_versao desc separator "@#$"),"@#$",1) as nome_versao,
    substring_index(group_concat(corpo_da_proposta order by nome_versao desc separator "@#$"),"@#$",1) as ultima_versao,
    substring_index(group_concat(nome_tipo_de_participacao order by nome_versao desc separator "@#$"),"@#$",1) as nome_tipo_de_participacao,
	group_concat(corpo_da_proposta order by nome_versao desc separator "@#$") as todas_versoes,
	id_chave_proposta
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
		$campos[$indice_conta][]=$row["todas_versoes"];
		$campos[$indice_conta][]=$row["id_chave_proposta"];
		$todas_versoes= explode("@#$",$row["todas_versoes"]);
		$indice_conta++;	
		$velho_grupo = $nome_grupo;
    }
} else {
    echo "Nenhum resultado encontrado.";
}

echo '
<!DOCTYPE html>
<html lang="pt">
	<head>
		<title>
CLNST
		</title>
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
  overflow-x: hidden;
  scroll-behavior: smooth;
  transition: scroll-behavior 0.5s;  
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
  overflow-y: scroll;
}

.proposta{
	border-bottom: 12px solid gray;
	background-color: rgba(25,100,100,0.8);
	color: white;
	padding: 1%;
}

.titulo_proposta {
	font-size:1.5rem;
	color: white;
	font-weight: bold;

}
.texto_proposta {
	font-size:1.3rem;
	color: white;

}
.horario_proposta {
	font-size:1.1rem;
	color: rgb(0,0,0,0.9);
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

.tabela_interna_da_proposta {
	border-collapse: collapse;

}

.tabela_do_participante {
	width: 100%;
	height: 100%;
	border-collapse: collapse;
	table-layout: fixed;
	border: 1px solid black;
}

.tabela_do_participante td {
	width: 1%;
	word-wrap: break-word;
	border: 1px solid black;
}
.botoes_proposta {
  background-color: rgba(0, 0, 0, 0.9);
  color: white;
  border: none;
  padding: 1px;
  cursor: pointer;
  font-size: 1.2rem;
  display: block;
  margin: 0;
  width: 98%;
}

.botoes_proposta:hover {
	background-color: rgba(0,0,0,0.5);
}

.botoes_proposta:active {
	background-color: rgba(0,0,1,0.5);
	border: 2px solid yellow;
}
.botoes_status {
  background-color: rgba(0, 0, 0, 0.9);
  color: white;
  border: none;
  padding: 2px;
  cursor: pointer;
  font-size: 2rem;
  display: block;
  margin: 0;
  width: 98%;
}

.botoes_status:hover {
	background-color: rgba(0,0,0,0.5);
}

.botoes_status:active {
	background-color: rgba(0,0,1,0.5);
	border: 2px solid yellow;
}
.botoes {
  background-color: rgba(0, 0, 0, 0.9);
  color: white;
  border: none;
  padding: 2px;
  cursor: pointer;
  font-size: 2rem;
  display: block;
  margin: 0 auto;
  width: 98%;
}

.botoes:hover {
	background-color: rgba(0,0,0,0.5);
}

.botoes:active {
	background-color: rgba(0,0,1,0.5);
	border: 2px solid yellow;
}

.cell_centrada {
	text-align: center;
	vertical-align: middle;
}

.cell_left {
	text-align: left;
	vertical-align: middle;
}

.cell_identidade {
	font-size: 2rem;
	font-weight: bold;
}

.cell_caption_mudanca_status {
	font-size: 1.5rem;
	font-weight: bold;
}

.cell_papel {
	font-size: 1.4rem;
	font-weight: bold;
}

.margem {
text-align: center;
}

.cell_status {
	font-size: 1.5rem;
	background-color: blue;
	color: white;
	font-weight: bold;
	padding: 0.5%;
	text-align: center;
	width: 60%;
	margin: 0 auto;
}

.linha_muda_status {
			height: 10px;
}

.cell_direita {
	text-align: right;
	vertical-align: middle;
}

.borda_direita {
    border-right: 1px solid black;
	padding-right: 10px;
}

.borda_esquerda {
    border-left: 1px solid black;
	padding-left: 10px;
}


</style>	</head>


<body>
<div class="entrada_de_dados">
<table class="tabela_do_participante">';
if (strpos($paineis, "mudanca_status")){
		echo '
		<tr class="linha_muda_status">
		<td class="cell_caption_mudanca_status ">Mude o Status aqui <b style="color: yellow; font-size: 2rem">&rarr;</b> </td>
		<td><button id="muda_status_propostas" class="botoes_status" onclick="">Abre para Propostas</button></td>
		<td><button id="muda_status_leitura" class="botoes_status" onclick="abre_destaques_e_votacoes()">Destaques e Votações</button></td>
		<td><button id="muda_status_inscricoes" class="botoes_status" onclick="">Inscrições para fala</button></td>
		<td><button id="muda_status_aguarde" class="botoes_status" onclick="">Aguarde<br>por favor</button></td>
		</tr>
		';

		}
	else {
	}

echo '<tr class="linha_muda_status">
		<td class="cell_left cell_identidade">
			'.$nome_participante_param.'
		</td>
		<td class="cell_centrada">
			<button id="adiciona_proposta" class="botoes" onclick="">Proposta +</button>
		</td>
		<td class="cell_centrada">';

if (strpos($paineis, "todos_grupos")){
		echo '<button id="meu_grupo" class="botoes" onclick="va_pro_meu_grupo(nome_grupo_param)">Meu Grupo</button>';
		}
	else {
	}


		echo '
		</td>
		<td class="cell_centrada">
			<button id="adiciona_proposta2" class="botoes" onclick="checa_status(`'.$nome_grupo_param.'`)">Sincroniza</button>
		</td>
		<td class="cell_direita">
			<img height="60" src="FUNDACENTRO-RSDATA.jpg" alt="logo da fundacentro">
		</td>
	</tr>
	<tr class="linha_muda_status">
		<td class="cell_left cell_papel">
			'.$papeis.'
		</td>
		<td>
		</td>
		<td>
		</td>
		<td class="cell_centrada margem">
			<div id="status" class="cell_status"></div>
		</td>
		<td class="cell_centrada cell_identidade">
			CLNST
		</td>
	</tr>
	<tr>
		<td>
		</td>
		<td>
		</td>
		<td>
		</td>
		<td>
		</td>
		<td>
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
    <div class="carousel-item active grupo" data-ordem="'.$conta_grupos.'" id="'.str_replace(" ", "_", $campos[$chave][0]).'">
	  <table class="tabela_do_grupo">
	  <tr>
      <td><b class="titulo">'.$campos[$chave][0].'<br></b><b class="subtitulo">(participação '.$campos[$chave][6].')</b></td>
	  <td><b class="diretriz">'.$campos[$chave][5].'</b></td>
	  </tr>';
	  $conta_grupos++;
}

echo '
<tr>
<td colspan="2">
		<div class="proposta" >
		<table class="tabela_interna_da_proposta" style="width: 100%">
			<tr>
				<td class="titulo_proposta borda_direita">			
						'.$campos[$chave][2].'
				</td>
				<td class="texto_proposta borda_esquerda">
						'.$campos[$chave][4].'
				</td>
			</tr>
			<tr>
				<td class="horario_proposta borda_direita">
					'.str_replace(" ", "<br>",$campos[$chave][3]).'
				</td>
				<td class="borda_esquerda">';

if (strpos($paineis, "insercao_proposta_votacao_inscricao_destaque") && $campos[$chave][0]==$nome_grupo_param && $status_transicao=="abrindo destaque ou votação"){
echo '
				<div>
				<table style="width: 100%" >
				<tr>
					<td><button id="abre_destaques" class="botoes_proposta" onclick="seta_status(`'.$nome_grupo.'`, `destaques de proposta`, '.$campos[$chave][8].')">Abre Destaques</button></td>
					<td><button id="fecha_destaques" class="botoes_proposta" onclick="">Fecha Destaques</button></td>
					<td><button id="abre_votacao" class="botoes_proposta" onclick="">Abre Votação</button></td>
					<td><button id="abre_votacao" class="botoes_proposta" onclick="">Fecha Votação</button></td>
				</tr>
				</table>
				</div>';
}
echo '
				</td>
			</tr>
		</table>
		</div>
</td>
</tr>';

$velho_grupo = $campos[$chave][0]; // nome_grupo
}
echo '
  </table>
  </div>
  </div>
</div>';

if (strpos($paineis, "todos_grupos")){

echo' <button id="tras" class="carousel-control prev" onclick="changeSlide(-1)">trás</button>
  <button id="frente" class="carousel-control next" onclick="changeSlide(1)">frente</button>';
}

 
echo '
<script>

function abre_destaques_e_votacoes(nome_grupo, status){
			var resposta="";
			var url="define_status.php?nome_grupo_param="+nome_grupo+"&status_param=abrindo destaque ou votação";
			var oReq=new XMLHttpRequest();
            oReq.open("GET", url, false);
            oReq.onload = function (e) {
                resposta=oReq.responseText;
				document.getElementById("status").innerText = resposta;
				location.reload();
                //alert(resposta);
            }
                oReq.send();

}

function seta_status(nome_grupo, status, proposta){
			var resposta="";
			var url="define_status.php?nome_grupo_param="+nome_grupo+"&status_param="+status+"&proposta_param="+proposta;
			var oReq=new XMLHttpRequest();
            oReq.open("GET", url, false);
            oReq.onload = function (e) {
                resposta=oReq.responseText;
				document.getElementById("status").innerText = resposta;
                //alert(resposta);
            }
                oReq.send();
}

function checa_status(nome_grupo){
			var resposta="";
			var url="verifica_status.php?nome_grupo_param="+nome_grupo;
			var oReq=new XMLHttpRequest();
            oReq.open("GET", url, false);
            oReq.onload = function (e) {
                resposta=oReq.responseText;
				status_do_grupo=resposta;
				document.getElementById("status").innerText = resposta;
                //alert(resposta);
            }
                oReq.send();
}

var status_do_grupo="'.$status_transicao.'";
var numero_grupos = '.$numero_grupos.';
var nome_grupo_param = "'.$nome_grupo_param.'";
var carrosel       = document.getElementById("carrosel");
var tripa_carrosel = document.getElementById("tripa_carrosel");
var divs_do_carrosel = document.getElementsByClassName("carrosel_item");

var botao_tras = document.getElementById("tras");
var botao_frente = document.getElementById("frente");
var posicaoAlvo= -1;
var scroll_dos_grupos = [];
var lista_de_grupos = document.getElementsByClassName("grupo");
var largura_item = tripa_carrosel.getBoundingClientRect().width / numero_grupos;

// botao_tras.style.top = carrosel.getBoundingClientRect().bottom; 

// carrosel.addEventListener("transitionend",function () {alert("tete"); carrosel.style.overflowX="hidden"} ); // nao estah funcionando


// Função para verificar se a animação de rolagem suave terminou
function verificarTerminoAnimacao() {
// alert(posicaoAlvo);
  //console.log(carrosel.scrollLeft);
  if (carrosel.scrollLeft >= posicaoAlvo) {
	carrosel.style.overflowX="hidden";
   // console.log("A animação de scroll terminou!");
  }
}

// Adicionar um ouvinte de evento ao elemento para o evento scroll
carrosel.addEventListener("scroll", verificarTerminoAnimacao);



document.getElementById("status").innerText = status_do_grupo; 
//alert(status_do_grupo);
function inicializa_posicoes(){
	for (var i=0; i < lista_de_grupos.length; i++){
		var elemento = lista_de_grupos[i];
		elemento.setAttribute("data-scroll", i*largura_item);
	}

}

function changeSlide(indice){

	
	carrosel.style.overflowX="scroll";
	posicaoAlvo =  carrosel.scrollLeft - indice * largura_item;
	carrosel.scrollLeft = posicaoAlvo;
//    setTimeout(function () {carrosel.style.overflowX="hidden"}, 2000); // gambi para permitir o scroll sem deixar o usuário usar... se o usuário for rápido ele consegue. Só é necessário no Firefox... no Chromium ele permite usar o scrollLeft mesmo com overflow hidden. o Settimeout eh necessario por causa do tempo de animação. 

}

function va_pro_meu_grupo(nome_grupo_param){
// alert( document.getElementById(nome_grupo_param.replace(/ /g,"_")).getAttribute("data-scroll"));

	carrosel.style.overflowX="scroll";
	posicaoAlvo=document.getElementById(nome_grupo_param.replace(/ /g,"_")).getAttribute("data-scroll");
	carrosel.scrollLeft =posicaoAlvo;
//	setTimeout(function () {carrosel.style.overflowX="hidden"}, 2000);
}


inicializa_posicoes();
va_pro_meu_grupo(nome_grupo_param);

</script>
</body>
</html>';
?>

