#!/bin/bash
IP_db=$(cut -d ":" -f 1 /home/$USER/.pgpass)
db_name='shop'
db_user='test'

#kategória felsorolás
list_category() {
    unset myarray
    unset idarray
    unset data
    ezlenne=""
    idvar=""
    azez=$(psql -t -h $IP_db -p 15432 -U test -d shop -c "SELECT * FROM categories")
    #azez=$($execute -h $IP_db -U test -d shop -c "SELECT * FROM categories")
    while IFS='|' read -r id nev description
    do
        ezlenne+="$nev "
        idvar+="$id "
    done <<< "$azez"
    read -a myarray <<< $ezlenne
    read -a idarray <<< $idvar
    for (( i=0; i<${#idarray[*]}; ++i)); do
    data+=( "${idarray[$i]}" "${myarray[$i]}" )
    done
#Ha rákattintunk egy kategóriára akkor az id-ját változóba mentjük, és átadjuk
#paraméterként a termék listázásnak, hogy az adott kategória termékeit megnézhessük.
    select=$(zenity --list --title="Kategóriák" --column="ID" --column="Név" "${data[@]}")
    if [ -n "$select" ]
    then
    list_products "$select"
    else
    listen
    fi
}

#termék felsorolás
list_products() {
    unset myarray
    unset idarray
    unset data
    ezlenne=""
    idvar=""
#Ellenőrizzük, hogy kaptunk-e paramétert, ha nem akkor mindent felsorolunk, ha igen,
#akkor csak az adott kategóriába tartozó termékek jelennek meg.
    if [ -n "$1" ]
    then
    azez=$(psql -t -h $IP_db -p 15432 -U test -d shop -c \
    "SELECT product_name, unit_price FROM products WHERE category_id = '$1'")
    else
    azez=$(psql -t -h $IP_db -p 15432 -U test -d shop -c \
    "SELECT product_name, unit_price FROM products")
    fi
    while IFS='|' read -r id nev description
    do
        ezlenne+="$nev "
        idvar+="$id "
    done <<< "$azez"
    read -a myarray <<< $ezlenne
    read -a idarray <<< $idvar
    for (( i=0; i<${#idarray[*]}; ++i)); do
    data+=( "${idarray[$i]}" "${myarray[$i]}" )
    done
    select=$(zenity --list --title="Termékek" --column="Név" --column="Ár" "${data[@]}" \
    --width=300 --height=500)
    if [ -n "$select" ]
    then
    inform=$(psql -t -h $IP_db -p 15432 -U test -d shop -c \
    "SELECT * FROM products WHERE product_name='$select'";)
    zenity --info \
    --text="$inform" --width=300 --height=150
    fi
    listen
}

#termék törlés
del_product() {
    unset myarray
    unset idarray
    unset data
    ezlenne=""
    idvar=""
    azez=$(psql -t -h $IP_db -p 15432 -U test -d shop -c "SELECT product_name, unit_price FROM products")
    while IFS='|' read -r id nev description
    do
        ezlenne+="$nev "
        idvar+="$id "
    done <<< "$azez"
    read -a myarray <<< $ezlenne
    read -a idarray <<< $idvar
    for (( i=0; i<${#idarray[*]}; ++i)); do
    data+=( "${idarray[$i]}" "${myarray[$i]}" )
    done
    select=$(zenity --list --title="Termékek" --column="Név" --column="Ár" "${data[@]}")
    if [ -n "$select" ]
    then
    inform=$(psql -t -h $IP_db -p 15432 -U test -d shop -c \
    "DELETE FROM products WHERE product_name='$select'";)
    zenity --info \
    --text="$select törölve!"
    fi
    listen
}

#jelenleg teszt funkció
help() {
    zenity --question \
        --text="Menjen, vagy ne?" --ok-label="Igen" --cancel-label="Ne"
    if [ "$?" = "1" ]
    then
    remote_server
    else
    zenity --info --text="Ez volt az igen!"
    fi
    listen
}

#Kategória hozzáadás
add_category() {
    add_cat=$(zenity --forms --title="Kategória hozzáadása" \
    --add-entry="Kategória neve" \
    --add-entry="Kategória leírása")
    if [ -n "$add_cat" ]
    then
    while IFS='|' read -r name description
    do
    psql -t -h $IP_db -p 15432 -U test -d shop -c \
    "INSERT INTO categories (category_name, description) VALUES ('$name', '$description') ;"
    done <<< "$add_cat"
    zenity --info \
    --text="Kategória létrehozva: $name!"
    else
    zenity --info \
    --text="Üres kategória nem hozható létre!"
    fi
    listen
}

#Termék hozzáadás
add_product() {
    add=$(zenity --forms --title="Termék hozzáadása" \
    --add-entry="Termék neve" \
    --add-entry="Termék kategóriája" \
    --add-entry="Termék ára")
    if [ -n "$add" ]
    then
    while IFS='|' read -r name cat price
    do
    psql -t -h $IP_db -p 15432 -U test -d shop -c \
    "INSERT INTO products (product_name, category_id, unit_price) VALUES ('$name', '$cat', '$price') ;"
    done <<< "$add"
    zenity --info \
    --text="Termék létrehozva: $name!"
    else
    zenity --info \
    --text="Üres termék nem hozható létre!"
    fi
    listen
}

#Távoli adatbázis elérés
#A kapott IP bekerül a .pgpass fájlba aminek a megfelelő jogosultágokat megadjuk
#utána környezeti változóba kerül, ezután már nem kér jelszavat sem a program, mivel az a fájlban van.
remote_server() {
IP_db=$(zenity --forms --title="Távoli adatbázis" \
--add-entry="IP cím")
pg_is_there=$(ls -la /home/$USER | grep -o .pgpass )
if [ "$pg_is_here" == ".pgpass" ]
then
echo $IP_db:15432:shop:test:test > /home/$USER/.pgpass
sudo chmod 600 /home/$USER/.pgpass
sudo chown $USER:$USER /home/$USER/.pgpass
export PGPASSFILE='/home/'$USER'/.pgpass'
listen
else
touch /home/$USER/.pgpass
echo $IP_db:15432:shop:test:test > /home/$USER/.pgpass
sudo chmod 600 /home/$USER/.pgpass
sudo chown $USER:$USER /home/$USER/.pgpass
export PGPASSFILE='/home/'$USER'/.pgpass'
listen
fi
}

#Főmenü
listen() {
ans=$(zenity --list --title "Menü" --radiolist --column "ID" --column="Funkció" \
1 'Felhasználó létrehozása' \
2 'Felhasználó törlése' \
3 'Termékek felsorolása' \
4 'Termék hozzáadása' \
5 'Termék törlése' \
6 'Kategória hozzáadása' \
7 'Kategóriák felsorolása' \
8 'Kapcsolódás távoli adatbázishoz' \
9 'teszt' --width=500 --height=500)
if [ "$ans" == "Kategóriák felsorolása" ]
then
list_category
elif [ "$ans" == "Felhasználó létrehozása" ]
then
listen
elif [ "$ans" == "Felhasználó törlése" ]
then
dbsetup
elif [ "$ans" == "Termék hozzáadása" ]
then
add_product
elif [ "$ans" == "Kategória hozzáadása" ]
then
add_category
elif [ "$ans" == "Termék törlése" ]
then
del_product
elif [ "$ans" == "Termékek felsorolása" ]
then
list_products
elif [ "$ans" == "teszt" ]
then
help
elif [ "$ans" == "Kapcsolódás távoli adatbázishoz" ]
then
listen
else
exit
fi
}

starter() {
    start=$(zenity --list --title "Menü" --radiolist --column "ID" --column "Funkció" \
    1 'Szerver' \
    2 'Kliens')
    if [ "$start" == "Szerver" ]
    then
        docact="$(systemctl status docker | grep -o "active")"
        if [ "$docact" == "active" ]
        then
        echo "Docker $docact"
        else
        zenity --question --text="Docker nem aktív! Másik gépre akar csatlakozni?" \
        --ok-label="Igen" --cancel-label="Nem"
        if [ "$?" = "0" ]
        then
        remote_server
        fi
        fi
        posact="$(docker ps | grep -o "postgres")"
        if [ "$posact" == "postgres" ]
        then
        echo "PostgreSQL aktív"
        listen
        else
        zenity --info --text="A PostgreSQL nem aktív! Lehet, hogy nincs minden telepítve?"
        exit
        fi
    elif [ "$start" == "Kliens" ]
    then
        remote_server
    fi
}
starter