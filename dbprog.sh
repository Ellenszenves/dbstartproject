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

#Felsorolás funkció
list() {
    azez=$(psql -U testdb -d testdb -c "SELECT * FROM public."categories"")
    zenity --info \
        --text="$azez"
    listen
}

#Help funkció
help() {
    zenity --info \
        --text="Kilépés: ctrl+c\n
          Parancsok: createrole: testdb felhasználó létrehozása\n
          dbsetup: Adatbázis létrehozása\n
          list: Termékek felsorolása\n
          add-product: Termék hozzáadása\n
          del-product: Termék törlése\n
          back: Visszalépés a főmenübe\n
          create-tables: Létrehozza a szükséges táblákat." --width=500 --height=500
    listen
}

#Telepítés indító funkció
setup() {
    zenity --text-info \
            --title="Setup" \
            --filename=licence.txt

    case $? in
    0)
    echo "Akkor induljunk!"
    help
    #sudo apt-get update
    #sudo apt-get install postgresql postgresql-contrib
    ;;
    1)
    echo "Akkor még nem telepítünk"
    listen
    ;;
    -1)
    echo "Váratlan hiba történt!"
    ;;
    esac
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
#sudo su - postgres
#psql postgres -c "CREATE DATABASE testDB;"
#echo "Adatbázis létrehozva!"
#Postgres felhasznaló létrehozása testdb néven
#psql -d testdb << EOF
#CREATE ROLE testdb WITH SUPERUSER CREATEDB CREATEROLE LOGIN ENCRYPTED PASSWORD 'testdb';
#EOF
#echo "testdb felhasználó elkészítve!"
#Táblák létrehozása, hibakereséssel.
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

#Figyeli mit szeretnénk csinálni
listen() {
ans=$(zenity --list --title "Menü" --radiolist --column "ID" --column="Funkció" 1 'Felhasználó létrehozása' 2 'Adatbázis létrehozása' 3 'Termékek felsorolása' 4 'Termék hozzáadása' 5 'Termék törlése' 6 'Táblák létrehozása')
if [ "$ans" == "Termékek felsorolása" ]
then
list &
listen
elif [ "$ans" == "Felhasználó létrehozása" ]
then
listen
elif [ "$ans" == "Adatbázis létrehozása" ]
then
dbsetup
elif [ "$ans" == "Termék hozzáadása" ]
then
add-product
elif [ "$ans" == "Termék törlése" ]
then
del-product
else
exit
fi
}
setup