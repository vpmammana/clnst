# este comando só permite criar os links se a lista de nomes não tiver homônimos. Tem que substituir por CPF para listas reais e não fictícias

cat nomes_cpfs_ficticios.txt | sed 's/, /,/g' | awk 'BEGIN{FS=",";}{print "INSERT INTO participantes_papeis (nome_participante_papel, id_participante, id_papel) VALUES (\""$1"-"$2"\", (SELECT id_chave_participante from participantes where nome_participante = \""$1"\"), (SELECT id_chave_papel from papeis where nome_papel = \""$2"\"));";}' > insere_links_ficticios.sql
