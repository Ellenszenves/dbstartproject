#!/bin/bash
#PostgreSQL: pg_hba.conf file-ba elsőként felsorolni: host all postgres 127.0.0.1/32 trust
#postgresql felhasználóval beléptem, adtam neki postgresql jelszót.
echo "Bolti adatbázis project by Erdélyi Tamás. 2021"
#Kiszedjük változóba a postgresql státuszt és megvizsgáljuk fut e.
posact="$(systemctl status postgresql | grep -o "active")"
if [ "$posact" == "active" ]
then
echo "PostgreSql $posact"
else
echo "PostgreSql nem aktív!"
fi

#Telepítés indító funkció
setup() {
read -p  "Üdv, kezdődhet a telepítés?" ans
if [[ "$ans" == "igen" ]]
then
echo "Akkor induljunk!"
#sudo apt-get update
#sudo apt-get install postgresql
else
echo "Akkor még nem telepítünk!"
fi
}

#Adatbázis létrehozás itt épp testDB néven
dbsetup() {
psql postgres -c "CREATE DATABASE testDB";
}
setup
