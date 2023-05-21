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
    id_chave_participante = 14 
    order by nome_grupo, nome_participante, nome_papel, nome_painel_de_interface;
