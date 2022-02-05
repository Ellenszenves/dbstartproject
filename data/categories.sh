#!/bin/bash
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
    select=$(zenity --list --title="Kategóriák" --column="ID" --column="Név" "${data[@]}" )
    if [ -n "$select" ]
    then
    source ./data/products.sh
    list_products "$select"
    else
    listen
    fi
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

#Kategória törlése
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