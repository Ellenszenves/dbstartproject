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

#Help funkció
help() {
    echo "Kilépés: ctrl+c
          Parancsok: add-product: Termék hozzáadása
                     del-product: Termék törlése
                     back: Visszalépés a főmenübe"
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
