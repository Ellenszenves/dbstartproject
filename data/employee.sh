#!/bin/bash
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

list_employee() {
    unset stockarray
    unset catarray
    unset myarray
    unset idarray
    unset data
    unset phonearray
    namevar=""
    titlevar=""
    phonevar=""
    emp=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c "SELECT employee_name, title, phone FROM employees")
    while IFS='|' read -r e_name e_title e_phone
    do
        namevar+="$e_name "
        titlevar+="$e_title "
        phonevar+="$e_phone|"
    done <<< "$emp"
    read -a myarray <<< $namevar
    read -a idarray <<< $titlevar
    IFS="|" read -a phonearray <<< $phonevar
    for (( i=0; i<${#idarray[*]}; ++i)); do
    data+=( "${myarray[$i]}" "${idarray[$i]}" "${phonearray[$i]}")
    done
    select=$(zenity --list --title="Munkatársak" --column="Név" --column="Beosztás" --column="Telefon" "${data[@]}" )
    listen
}
