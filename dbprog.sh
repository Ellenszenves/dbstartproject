#!/bin/bash
db_name='shop'
db_user='test'
echo "Bolti adatbázis project by Erdélyi Tamás. 2022"
#Kiszedjük változóba a docker státuszt és megvizsgáljuk fut e.
posact="$(systemctl status docker | grep -o "active")"
if [ "$posact" == "active" ]
then
echo "Docker $posact"
else
echo "Docker nem aktív!"
fi

#Felsorolás funkció
list() {
    #kilistázzuk a kategóriákat
    azez=$(docker exec dbstartproject_db_1 psql -U $db_user -d $db_name -c "SELECT * FROM categories")
    #itt pedig egy változóba listázzuk a neveket
    catnames=$(while IFS='|' read -r id nev desc
    do
    echo "$nev"
    done <<< "$azez")
    #végül kiíratjuk zenityvel
    zenity --info \
        --text="$catnames" --width=500 --height=500
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
    #sudo apt-get install -y docker
    #sudo apt-get install -y docker-compose
    #sudo usermod -aG docker $USER
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
    name=$(zenity --entry \
    --title="Új termék" \
    --text="Termék neve" \
    --entry-text="termék")
    barcode=$(zenity --entry \
    --title="Új termék" \
    --text="Vonalkód" \
    --entry-text="0000")
    echo $name, $barcode
listen
}

#Kategória hozzáadás
add-category() {
    name=$(zenity --entry \
    --title="Új kategória" \
    --text="Kategória neve" \
    --entry-text="kategória")
    descr=$(zenity --entry \
    --title="Új kategória" \
    --text="Kategória leírása" \
    --entry-text="leírás")
    if [ -n "$name" ]
    then
    docker exec dbstartproject_db_1 psql -U $db_user -d $db_name -c "INSERT INTO categories (category_name, description) VALUES ('$name', '$descr') ;"
    zenity --info \
    --text="Kategória létrehozva: $name, $descr!"
    else
    zenity --info \
    --text="Üres kategória nem hozható létre!"
    fi
    listen
}

#Figyeli mit szeretnénk csinálni
listen() {
ans=$(zenity --list --title "Menü" --radiolist --column "ID" --column="Funkció" \
1 'Felhasználó létrehozása' \
2 'Adatbázis létrehozása' \
3 'Termékek felsorolása' \
4 'Termék hozzáadása' \
5 'Termék törlése' \
6 'Táblák létrehozása' \
7 'Kategória hozzáadása')
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
elif [ "$ans" == "Kategória hozzáadása" ]
then
add-category
elif [ "$ans" == "Termék törlése" ]
then
del-product
else
exit
fi
}
setup
