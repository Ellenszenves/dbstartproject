#!/bin/bash
db_name='shop'
db_user='test'
execute='docker exec dbstartproject_db_1 psql -t -U test -d shop -c'
echo "Bolti adatbázis project by Erdélyi Tamás. 2022"
#Kiszedjük változóba a docker státuszt és megvizsgáljuk fut e.
docact="$(systemctl status docker | grep -o "active")"
if [ "$docact" == "active" ]
then
echo "Docker $docact"
else
echo "Docker nem aktív!"
fi
posact="$(docker ps | grep -o "postgres")"
if [ "$posact" == "postgres" ]
then
echo "PostgreSQL aktív"
else
echo "A PostgreSQL nem aktív!"
fi

#kategória felsorolás
list() {
    unset myarray
    unset idarray
    unset data
    ezlenne=""
    idvar=""
    azez=$($execute "SELECT * FROM categories")
    echo $azez
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
    zenity --list --title="Kategóriák" --column="ID" --column="Név" "${data[@]}"
    listen
}

#termék felsorolás
list_products() {
    unset myarray
    unset idarray
    unset data
    echo ${data[0]}
    ezlenne=""
    idvar=""
    azez=$($execute "SELECT product_name, unit_price FROM products")
    echo $azez
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
    inform=$($execute "SELECT * FROM products WHERE product_name='$select'";)
    zenity --info \
    --text="$inform"
    fi
    listen
}

#termék törlés
del_product() {
    ezlenne=""
    idvar=""
    azez=$($execute "SELECT product_name, unit_price FROM products")
    echo $azez
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
    inform=$($execute "DELETE FROM products WHERE product_name='$select'";)
    zenity --info \
    --text="$select törölve!"
    fi
    listen
}

#jelenleg teszt funkció
help() {
    zenity --info \
        --text="README" \
    listen
}

help1() {
    zenity --list \
            --column="név" --column="teszt" \
            ez az amaz emez szir szar \
            --height=500 --width=500 \
            --position=10%=10%
}

#Telepítés indító funkció
setup() {
    zenity --text-info \
            --title="Setup" \
            --filename=licence.txt

    case $? in
    0)
    echo "Akkor induljunk!"
    listen
    #sudo apt-get update
    #sudo apt-get install -y docker
    #sudo apt-get install -y docker-compose
    #sudo usermod -aG docker $USER
    #docker-compose up -d
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

#Kategória hozzáadás
add_category() {
    add_cat=$(zenity --forms --title="Kategória hozzáadása" \
    --add-entry="Kategória neve" \
    --add-entry="Kategória leírása")
    if [ -n "$add_cat" ]
    then
    while IFS='|' read -r name description
    do
    $execute "INSERT INTO categories (category_name, description) VALUES ('$name', '$description') ;"
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
    $execute "INSERT INTO products (product_name, category_id, unit_price) VALUES ('$name', '$cat', '$price') ;"
    done <<< "$add"
    zenity --info \
    --text="Termék létrehozva: $name!"
    else
    zenity --info \
    --text="Üres termék nem hozható létre!"
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
7 'Kategória hozzáadása' \
8 'Kategóriák felsorolása' \
9 'teszt' --width=500 --height=500)
if [ "$ans" == "Kategóriák felsorolása" ]
then
list
elif [ "$ans" == "Felhasználó létrehozása" ]
then
listen
elif [ "$ans" == "Adatbázis létrehozása" ]
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
help &
help1
else
exit
fi
}
setup
