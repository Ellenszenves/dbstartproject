#!/bin/bash
IP_db=$(cut -d ":" -f 1 /home/$USER/.pgpass)
db_name=$(cut -d ":" -f 3 /home/$USER/.pgpass)
db_user=$(cut -d ":" -f 4 /home/$USER/.pgpass)

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

#Eladó hozzáadása
add_employee() {
    add=$(zenity --forms --title="Munkatárs hozzáadása" \
    --add-entry="Név" \
    --add-entry="Beosztás" \
    --add-entry="Telefonszám")
    if [ -n "$add" ]
    then
    while IFS='|' read -r ename title phone
    do
        psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
        "INSERT INTO employees (employee_name, title, phone) VALUES ('$ename', '$title', '$phone') ;"
    done <<< "$add"
    zenity --info \
    --text="Munkatárs hozzáadva!"
    else
    zenity --info \
    --text="Ne hagyja üresen a mezőket!"
    fi
    listen
}

#Távoli adatbázis elérés
#A kapott IP bekerül a .pgpass fájlba aminek a megfelelő jogosultágokat megadjuk
#utána környezeti változóba kerül, ezután már nem kér jelszavat sem a program, mivel az a fájlban van.
remote_server() {
    IP_db=$(zenity --forms --title="Távoli adatbázis" \
    --add-entry="IP cím" \
    --add-entry="Felhasználónév" \
    --add-entry="Jelszó" \
    --add-entry="Adatbázis neve")
    if [ -n "$IP_db" ]
    then
    while IFS='|' read -r protocoll username passwo data
        do
        pg_is_there=$(ls -la /home/$USER | grep -o .pgpass )
            if [ "$pg_is_here" == ".pgpass" ]
            then
            echo $protocoll:15432:$data:$username:$passwo > /home/$USER/.pgpass
            sudo chmod 600 /home/$USER/.pgpass
            sudo chown $USER:$USER /home/$USER/.pgpass
            export PGPASSFILE='/home/'$USER'/.pgpass'
            zenity --info --text="Kérem indítsa újra a programot!"
            listen
            else
            touch /home/$USER/.pgpass
            echo $protocoll:15432:$data:$username:$passwo > /home/$USER/.pgpass
            sudo chmod 600 /home/$USER/.pgpass
            sudo chown $USER:$USER /home/$USER/.pgpass
            export PGPASSFILE='/home/'$USER'/.pgpass'
            zenity --info --text="Kérem indítsa újra a programot!"
            listen
            fi
        done <<< "$IP_db"
    else
    zenity --info --text="Ne hagyja üresen a mezőket!"
    remote_server
    fi
}

#Pár infó a programhoz
server_info() {
    ipvar=$(ip address show enp0s3 | grep -w "inet" | cut -c 5- | cut -d " " -f 2)
    zenity --info --text="IP cím: $ipvar \
    Adatbázis neve: $db_name \
    Felhasználó: $db_user" --width=400 --height=300
    listen
}

#Főmenü
listen() {
    ans=$(zenity --list --title "Menü" --radiolist --column "ID" --column="Funkció" \
    1 'Termék hozzáadása' \
    2 'Termékek felsorolása' \
    3 'Termék törlése' \
    4 'Kategória hozzáadása' \
    5 'Kategóriák felsorolása' \
    6 'Kategória törlése' \
    7 'Vásárló hozzáadása' \
    8 'Vásárlók listázása' \
    9 'Munkatárs hozzáadása' \
    10 'Számlázás' \
    11 'Kapcsolódás távoli adatbázishoz' \
    12 'Rendszerinformáció' --width=500 --height=500)
    if [ "$ans" == "Kategóriák felsorolása" ]
    then
    source ./data/categories.sh
    list_category
    elif [ "$ans" == "Kategória törlése" ]
    then
    source ./data/categories.sh
    del_category
    elif [ "$ans" == "Vásárló hozzáadása" ]
    then
    source ./data/customers.sh
    add_customer
    elif [ "$ans" == "Vásárlók listázása" ]
    then
    source ./data/customers.sh
    list_customers
    elif [ "$ans" == "Termék hozzáadása" ]
    then
    source ./data/products.sh 
    add_product
    elif [ "$ans" == "Kategória hozzáadása" ]
    then
    source ./data/categories.sh
    add_category
    elif [ "$ans" == "Termék törlése" ]
    then
    source ./data/products.sh 
    del_product
    elif [ "$ans" == "Termékek felsorolása" ]
    then
    source ./data/products.sh 
    list_products
    elif [ "$ans" == "Munkatárs hozzáadása" ]
    then
    add_employee
    elif [ "$ans" == "Számlázás" ]
    then
    source ./data/orders.sh
    new_order
    elif [ "$ans" == "Rendszerinformáció" ]
    then
    server_info
    elif [ "$ans" == "Kapcsolódás távoli adatbázishoz" ]
    then
    remote_server
    else
    exit
    fi
}

starter() {
    start=$(zenity --list --title "Menü" --radiolist --column "ID" --column "Funkció" \
    1 'Belépés' \
    2 'Távoli szerver adatai')
    if [ "$start" == "Belépés" ]
    then
        docact="$(systemctl status postgresql | grep -o "active")"
        if [ "$docact" == "active" ]
        then
        echo "Adatbázis $docact"
        else
        zenity --question --text="Docker nem aktív! Másik gépre akar csatlakozni?" \
        --ok-label="Igen" --cancel-label="Nem"
        if [ "$?" = "0" ]
        then
        remote_server
        fi
        fi
        psteszt=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
        "SELECT teszt FROM teszt" | grep -o "aaaaa")
        if [ "$psteszt" == "aaaaa" ]
        then
        echo "Adatbázis elérhető"
        listen
        else
        zenity --info --text="A PostgreSQL nem aktív! Lehet, hogy nincs minden telepítve?"
        exit
        fi
    elif [ "$start" == "Távoli szerver adatai" ]
    then
        remote_server
    fi
}
starter