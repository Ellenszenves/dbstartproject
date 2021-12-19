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

zenity() {
zenity --list \
  --title="Válassza ki a megjelenítendő hibajegyeket" \
  --column="Hiba száma" --column="Súlyosság" --column="Leírás" \
    992383 Normal "GtkTreeView crashes on multiple selections" \
    293823 High "GNOME Dictionary does not handle proxy" \
    393823 Critical "Menu editing does not work in GNOME 2.0"
}

#Postgres felhasznaló létrehozása
createrole() {
psql -d testdb << EOF
CREATE ROLE testdb WITH SUPERUSER CREATEDB CREATEROLE LOGIN ENCRYPTED PASSWORD 'testdb';
EOF
echo "testdb felhasználó elkészítve!"
listen
}

#Táblák létrehozása, hibakereséssel.
create-tables() {
user_id="$(psql -qt testdb -d testdb -c "
SELECT category_id FROM categories WHERE category_name = 'dummy'"
)"
if [ -n "$user_id" ]
then
echo "A tábla már létezik: Kategóriák"
listen
else
psql -U testdb -d testdb -c "CREATE TABLE categories (
    category_id SERIAL UNIQUE,
    category_name character varying(15) NOT NULL,
    description text,
    picture bytea
);
INSERT INTO categories (category_name, description) VALUES ('dummy', 'dummy') ;"
    echo "Tábla létrehozva: Kategóriák"
    listen
fi
}

#Help funkció
help() {
    echo "Kilépés: ctrl+c
          Parancsok: createrole: testdb felhasználó létrehozása
                     dbsetup: Adatbázis létrehozása
                     add-product: Termék hozzáadása
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
    read -p "Vonalkód:" barc
    echo "Termék $barc törölve!"
    del-product
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

#Hozzáadás
add-product() {
    read -p "Termék neve:" name
    read -p "Vonalkód:" barcode
echo "$name $barcode hozzáadva!"
listen
}

#Adatbázis létrehozás itt épp testDB néven
dbsetup() {
psql postgres -c "CREATE DATABASE testDB";
echo "Adatbázis létrehozva!"
listen
}

#Figyeli mit szeretnénk csinálni
listen() {
read -p "Várom a parancsot!" ans
$ans
if [[ $? != "0" ]]
then
echo "Rossz parancs, help a segítség megjelenítése."
listen
fi
}
setup