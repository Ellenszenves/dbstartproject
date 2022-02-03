#!/bin/bash
IP_db=$(cut -d ":" -f 1 /home/$USER/.pgpass)
db_name=$(cut -d ":" -f 3 /home/$USER/.pgpass)
db_user=$(cut -d ":" -f 4 /home/$USER/.pgpass)

#kategória felsorolás
list_category() {
    unset stockarray
    unset catarray
    unset myarray
    unset idarray
    unset data
    namevar=""
    idvar=""
    cats=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c "SELECT * FROM categories")
    while IFS='|' read -r id nev description
    do
        namevar+="$nev "
        idvar+="$id "
    done <<< "$cats"
    read -a myarray <<< $namevar
    read -a idarray <<< $idvar
    for (( i=0; i<${#idarray[*]}; ++i)); do
    data+=( "${idarray[$i]}" "${myarray[$i]}" )
    done
#Ha rákattintunk egy kategóriára akkor az id-ját változóba mentjük, és átadjuk
#paraméterként a termék listázásnak, hogy az adott kategória termékeit megnézhessük.
    select=$(zenity --list --title="Kategóriák" --column="ID" --column="Név" "${data[@]}" )
    if [ -n "$select" ]
    then
    list_products "$select"
    else
    listen
    fi
}

#termék felsorolás
list_products() {
    unset stockarray
    unset catarray
    unset myarray
    unset idarray
    unset data
    ezlenne=""
    idvar=""
#Ellenőrizzük, hogy kaptunk-e paramétert, ha nem akkor mindent felsorolunk, ha igen,
#akkor csak az adott kategóriába tartozó termékek jelennek meg.
    if [ -n "$1" ]
    then
    prods=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "SELECT product_name, unit_price, category_name, units_in_stock FROM products LEFT JOIN categories \
    ON products.category_id = categories.category_id WHERE products.category_id = '$1'")
    else
    prods=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "SELECT product_name, unit_price, category_name, units_in_stock FROM products LEFT JOIN categories \
    ON products.category_id = categories.category_id")
    fi
    echo $prods
#Itt szétbontjuk az eredményt annyi részre, ahány rekordot lekértünk, utána
#array-be helyezzük és összefűzzük őket, így a zenity tudja őket kezelni, és külön kiírni.
    while IFS='|' read -r namme price cat stock
    do
        ezlenne+="$price "
        idvar+="$namme|"
        cattvar+="$cat|"
        stockvar+="$stock|"
    done <<< "$prods"
    read -a myarray <<< $ezlenne
    IFS="|" read -a idarray <<< $idvar
    IFS="|" read -a catarray <<< $cattvar
    IFS="|" read -a stockarray <<< $stockvar
    for (( i=0; i<${#idarray[*]}; ++i)); do
    data+=( "${idarray[$i]}" "${myarray[$i]}" "${catarray[$i]}" "${stockarray[$i]}")
    done
    select=$(zenity --list --title="Termékek" --column="Név" --column="Ár" --column="Kategória" --column="Készlet" "${data[@]}" \
    --width=400 --height=500)
    cutted=$(echo $select | cut -b 1-)
#Ha duplán kattintunk egy termékre, módosíthatjuk a tulajdonságait.
    if [ -n "$select" ]
    then
    inform=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "SELECT product_name, unit_price, category_name, units_in_stock FROM products LEFT JOIN categories \
    ON products.category_id = categories.category_id WHERE product_name = '$cutted';")
    infoprice=$(echo $inform | cut -d "|" -f 2)
    infocat=$(echo $inform | cut -d "|" -f 3)
    infostock=$(echo $inform | cut -d "|" -f 4)
    egylista+=( "$cutted" "$infoprice" "$infocat" "$infostock" )
    #atya=$(zenity --list --editable --column="Típus:" --column="Érték" "Név:" "$cutted" "Ár:" "$infoprice" "Kategória:" "$infocat" "Készlet:" "$infostock")
    mod=$(zenity --list --title="Módosítás" --radiolist --column="ID" --column="Funkció" \
    1 'Név' 2 'Ár' 3 'Kategória' 4 'Készlet')
    if [ "$mod" == "Név" ]
    then
    namemod=$(zenity --forms --title=$cutted \
    --add-entry="Új név")
    elif [ "$mod" == "Ár" ]
    then
    pricemod=$(zenity --forms --title=$cutted \
    --add-entry="Új Ár")
    elif [ "$mod" == "Kategória" ]
    then
    catmod=$(zenity --forms --title=$cutted \
    --add-entry="Új kategória")
    elif [ "$mod" == "Készlet" ]
    then
    stockmod=$(zenity --forms --title=$cutted \
    --add-entry="Új készlet")
    fi
    else
    listen
    fi
    listen
}

#termék törlés
del_product() {
    unset stockarray
    unset catarray
    unset myarray
    unset idarray
    unset data
    ezlenne=""
    idvar=""
    azez=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c "SELECT product_name, unit_price FROM products")
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
    inform=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "DELETE FROM products WHERE product_name='$select'";)
    zenity --info \
    --text=$select" törölve!"
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
    psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
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
    --add-entry="Termék kategóriája(ID)" \
    --add-entry="Termék ára" \
    --add-entry="Darabszám")
    if [ -n "$add" ]
    then
    while IFS='|' read -r name cat price stock
    do
    psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "INSERT INTO products (product_name, category_id, unit_price, units_in_stock) VALUES ('$name', '$cat', '$price', '$stock') ;"
    done <<< "$add"
    zenity --info \
    --text=$name" létrehozva!"
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

server_info() {
    ipvar=$(ip address show enp0s3 | grep -w "inet" | cut -c 5- | cut -d " " -f 2)
    zenity --info --text="IP cím: $ipvar \
    Adatbázis neve: $db_name \
    Felhasználó: $db_user" --width=400 --height=300
    listen
}

del_category() {
    unset stockarray
    unset catarray
    unset myarray
    unset idarray
    unset data
    ezlenne=""
    idvar=""
    cats=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c "SELECT * FROM categories")
    while IFS='|' read -r id nev description
    do
        ezlenne+="$nev "
        idvar+="$id "
    done <<< "$cats"
    read -a myarray <<< $ezlenne
    read -a idarray <<< $idvar
    for (( i=0; i<${#idarray[*]}; ++i)); do
    data+=( "${idarray[$i]}" "${myarray[$i]}" )
    done
    select=$(zenity --list --title="Kategóriák" --column="ID" --column="Név" "${data[@]}" )
    if [ -n "$select" ]
    then
    inform=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "DELETE FROM categories WHERE category_id='$select'";)
    zenity --info \
    --text="Kategória törölve!"
    fi
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
    7 'Kapcsolódás távoli adatbázishoz' \
    8 'Rendszerinformáció' --width=500 --height=500)
    if [ "$ans" == "Kategóriák felsorolása" ]
    then
    list_category
    elif [ "$ans" == "Kategória törlése" ]
    then
    del_category
    elif [ "$ans" == "Felhasználó törlése" ]
    then
    del_user
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