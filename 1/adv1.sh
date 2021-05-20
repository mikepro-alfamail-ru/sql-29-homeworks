pg_dump -h84.201.163.203 -p19001 -Unetology -d'dvd-rental' -W -Fp -s -v -f db-schema.sql
pg_dump -h84.201.163.203 -p19001 -Unetology -d'dvd-rental' -W -Fc -v -T*_id_seq -f full-dump.sql
psql -c "CREATE DATABASE \"dvd-rental\";"
psql -c "CREATE USER netology;"
psql -d dvd-rental <db-schema.sql
pg_restore -a -d dvd-rental -Fc full-dump.sql
