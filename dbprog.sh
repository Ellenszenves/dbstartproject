#!/bin/bash
#PostgreSQL: pg_hba.conf file-ba elsőként felsorolni: host all postgres 127.0.0.1/32 trust
#postgresql felhasználóval beléptem, adtam neki postgresql jelszót.
#user=$(zenity --entry --text 'Please enter the username:') || exit 1
echo "Bolti adatbázis project by Erdélyi Tamás. 2021"
#Kiszedjük változóba a postgresql státuszt és megvizsgáljuk fut e.
posact="$(systemctl status postgresql | grep -o "active")"
if [ "$posact" == "active" ]
then
echo "PostgreSql $posact"
else
echo "PostgreSql nem aktív!"
fi

#Táblák létrehozása, hibakereséssel.
create-tables() {
    user_id="$(psql -qt postgres -d testdb -c "
SELECT category_id FROM public."categories" WHERE category_name = 'dummy'"
)"
if [ -n "$user_id" ]
then
echo "A tábla már létezik: Kategóriák"
listen
else
psql -U postgres -d testdb -c "CREATE TABLE categories (
    category_id SERIAL UNIQUE,
    category_name character varying(15) NOT NULL,
    description text,
    picture bytea
);
INSERT INTO public."categories" (category_name, description) VALUES (dummy, This is just a dummy product!) ;"
    echo "Tábla létrehozva: Kategóriák"
    listen
fi
}

#Help funkció
help() {
    echo "Kilépés: ctrl+c
          Parancsok: add-product: Termék hozzáadása
                     del-product: Termék törlése
                     back: Visszalépés a főmenübe
                     create-tables: Létrehozza a szükséges táblákat."
    listen
}

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
listen
fi
}

#Innentől a törlések
del-product() {
    read -p "Mi alapján töröljek?" iddel
    if [[ "$iddel" == "barcode" ]]
    then
    barDel
    elif [[ "$iddel" == "name" ]]
    then
    read -p "Termék neve:" name
    echo "$name törölve!"
    del-product
    elif [[ "$iddel" == "id" ]]
    then
    read -p "Termék azonosítója:" azon
    echo "$azon termék törölve!"
    del-product
    elif [[ "$iddel" == "back" ]]
    then
    listen
    fi
    }

barDel() {
read -p "Vonalkód:" barc
echo "Termék $barc törölve!"
del-product
}

#Hozzáadás
add-product() {
    read -p "Termék neve:" name
    read -p "Vonalkód:" barcode
echo "$name $barcode hozzáadva!"
listen
}

#Figyeli mit szeretnénk csinálni
listen() {
read -p "Várom a parancsot!" ans
if [[ "$ans" == "add-product" ]]
then
add-product
elif [[ "$ans" == "-help" ]]
then
help
elif [[ "$ans" == "del-product" ]]
then
del-product
elif [[ "$ans" == "create-tables" ]]
then
create-tables
else
echo "Rossz parancs, -help a segítség megjelenítése."
listen
fi
}

#Adatbázis létrehozás itt épp testDB néven
dbsetup() {
psql postgres -c "CREATE DATABASE testDB";
}
setup
