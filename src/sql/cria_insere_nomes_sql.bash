cat nomes_cpfs_ficticios.txt | sed 's/, /,/g' | awk 'BEGIN{FS=",";}{print "INSERT INTO participantes (nome_participante, cpf) VALUES (\""$1"\",\""$3"\");";}' > insere_nomes_ficticios.sql
