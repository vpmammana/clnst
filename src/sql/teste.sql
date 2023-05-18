UPDATE participantes as p SET p.id_grupo = ( SELECT id_chave_grupo FROM ( SELECT (@row_number:=@row_number + 1) AS row_number, id_chave_grupo FROM grupos) AS t WHERE t.row_number = p.id_chave_participante % @count + 1);

