#!/bin/bash
#Termék hozzáadás
add_product() {
    add=$(zenity --forms --title="Termék hozzáadása" \
    --add-entry="Termék neve" \
    --add-entry="Termék kategóriája" \
    --add-entry="Termék ára" \
    --add-entry="Darabszám")
    if [ -n "$add" ]
    then
    while IFS='|' read -r name cat price stock
    do
        catid=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
        "SELECT category_id FROM categories WHERE category_name = '$cat';")
            if [ $catid -ge 0 ]
            then
            psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
            "INSERT INTO products (product_name, category_id, unit_price, units_in_stock) VALUES ('$name', '$catid', '$price', '$stock') ;"
            else
            zenity --info --text="Nincs ilyen kategória!"
            add_product
            fi
    done <<< "$add"
    zenity --info \
    --text=$name" létrehozva!"
    else
    zenity --info \
    --text="Üres termék nem hozható létre!"
    fi
    listen
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
    cattvar=""
    stockvar=""
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
    if [ -n "$select" ]
    then
    product_mod "$cutted"
    else
    listen
    fi
}

#Termék tulajdonságainak módosítása
product_mod() {
    mod=$(zenity --list --title="Módosítás" --radiolist --column="ID" --column="Funkció" \
    1 'Név' 2 'Ár' 3 'Kategória' 4 'Készlet')
        if [ "$mod" == "Név" ]
        then
        namemod=$(zenity --forms --title=$1 \
        --add-entry="Új név")
            if [ -n "$namemod" ]
            then
            namemodded=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
            "UPDATE products SET product_name = '$namemod' WHERE product_name = '$1';")
            zenity --info --text="Termék neve módosítva!"
            else
            zenity --info --text="Üresen hagyott mező!"
            fi
        elif [ "$mod" == "Ár" ]
        then
        pricemod=$(zenity --forms --title=$1 \
        --add-entry="Új Ár")
            if [ -n "$pricemod" ]
            then
            pricemodded=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
            "UPDATE products SET unit_price = '$pricemod' WHERE product_name = '$1';")
            zenity --info --text="Termék ára módosítva!"
            else
            zenity --info --text="Üresen hagyott mező!"
            fi
        elif [ "$mod" == "Kategória" ]
        then
        catmod=$(zenity --forms --title=$1 \
        --add-entry="Új kategória")
            if [ -n "$catmod" ]
            then
            catmodded=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
            "UPDATE products SET category_id = '$catmod' WHERE product_name = '$1';")
            zenity --info --text="Termék kategóriája módosítva!"
            else
            zenity --info --text="Üresen hagyott mező!"
            fi
        elif [ "$mod" == "Készlet" ]
        then
        stockmod=$(zenity --forms --title=$1 \
        --add-entry="Új készlet")
            if [ -n "$stockmod" ]
            then
            stockmodded=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
            "UPDATE products SET units_in_stock = '$stockmod' WHERE product_name = '$1';")
            zenity --info --text="Termék darabszáma módosítva!"
            else
            zenity --info --text="Üresen hagyott mező!"
            fi
        fi
list_products
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

menu() {
    ans=$(zenity --list --title "Menü" --radiolist --column "ID" --column="Funkció" \
    1 'Termék hozzáadása' \
    2 'Termékek listája' \
    3 'Termék módosítása' \
    4 'Termék törlése' )
    if [ "$ans" == "Termék hozzáadása" ]
    then
    add_product
    elif [ "$ans" == "Termékek listája" ]
    then
    list_products
    elif [ "$ans" == "Termék módosítása" ]
    then
    product_mod
    elif [ "$ans" == "Termék törlése" ]
    then
    del_product
    else
    listen
    fi
}