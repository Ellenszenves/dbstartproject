#!/bin/bash
#Vásárló hozzáadása
add_customer() {
    add=$(zenity --forms --title="Vásárló hozzáadása" \
    --add-entry="Vásárló neve" \
    --add-entry="Adószám" \
    --add-entry="Város" \
    --add-entry="Cím" \
    --add-entry="Telefonszám")
    if [ -n "$add" ]
    then
    while IFS='|' read -r name tax city address tel
    do
    psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "INSERT INTO customers (contact_name, tax, city, address, phone) VALUES ('$name', '$tax', '$city', '$address', '$tel') ;"
    done <<< "$add"
    zenity --info --text="Vásárló létrehozva!"
    listen
    else
    zenity --info --text="Üres mező nem adható meg!"
    fi
    listen
}

#Vásárlók kilistázása
list_customers() {
    unset namearray
    unset taxarray
    unset cityarray
    unset addressarray
    unset telarray
    unset data
    namevar=""
    taxvar=""
    cityvar=""
    addressvar=""
    telvar=""
    custs=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c "SELECT contact_name, tax, city, address, phone FROM customers")
    while IFS='|' read -r name tax city address tel
    do
        namevar+="$name|"
        taxvar+="$tax "
        cityvar+="$city|"
        addressvar+="$address|"
        telvar+="$tel|"
    done <<< "$custs"
    IFS="|" read -a namearray <<< $namevar
    read -a taxarray <<< $taxvar
    IFS="|" read -a cityarray <<< $cityvar
    IFS="|" read -a addressarray <<< $addressvar
    IFS="|" read -a telarray <<< $telvar
    for (( i=0; i<${#namearray[*]}; ++i)); do
    data+=( "${namearray[$i]}" "${taxarray[$i]}" "${cityarray[$i]}" "${addressarray[$i]}" "${telarray[$i]}")
    done
    select=$(zenity --list --title="Vásárlók" --column="Név" --column="Adószám" \
    --column="Város" --column="Cím" --column="Telefonszám" "${data[@]}" --height=400 --width=700 )
    listen
}

modify_customer() {
    zenity --info --text="Itt lesz a vásárló módosítás funkció."
}

del_customer() {
    unset namearray
    unset taxarray
    unset cityarray
    unset addressarray
    unset telarray
    unset data
    namevar=""
    taxvar=""
    cityvar=""
    addressvar=""
    telvar=""
    custs=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c "SELECT contact_name, tax, city, address, phone FROM customers")
    while IFS='|' read -r name tax city address tel
    do
        namevar+="$name|"
        taxvar+="$tax "
        cityvar+="$city|"
        addressvar+="$address|"
        telvar+="$tel|"
    done <<< "$custs"
    IFS="|" read -a namearray <<< $namevar
    read -a taxarray <<< $taxvar
    IFS="|" read -a cityarray <<< $cityvar
    IFS="|" read -a addressarray <<< $addressvar
    IFS="|" read -a telarray <<< $telvar
    for (( i=0; i<${#namearray[*]}; ++i)); do
    data+=( "${namearray[$i]}" "${taxarray[$i]}" "${cityarray[$i]}" "${addressarray[$i]}" "${telarray[$i]}")
    done
    select=$(zenity --list --title="Vásárlók" --column="Név" --column="Adószám" \
    --column="Város" --column="Cím" --column="Telefonszám" "${data[@]}" --height=400 --width=700 )
    if [ -n "$select" ]
    then
    inform=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "DELETE FROM customers WHERE contact_name='$select'";)
    zenity --info \
    --text="Vásárló törölve!"
    fi
    listen
}

menu() {
    ans=$(zenity --list --title "Menü" --radiolist --column "ID" --column="Funkció" \
    1 'Vásárló hozzáadása' \
    2 'Vásárlók listája' \
    3 'Vásárló törlése' )
    if [ "$ans" == "Vásárló hozzáadása" ]
    then
    add_customer
    elif [ "$ans" == "Vásárlók listája" ]
    then
    list_customers
    elif [ "$ans" == "Vásárló törlése" ]
    then
    del_customer
    else
    listen
    fi
}