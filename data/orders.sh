#!/bin/bash

new_order() {
    add=$(zenity --forms --title="Új számla" \
    --add-entry="Vásárló neve" \
    --add-entry="Eladó neve" \
    --add-entry="Cég ID" )
    if [ -n "$add" ]
    then
    while IFS='|' read -r customer employee company
    do
        customerid=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
        "SELECT customer_id FROM customers WHERE company_name = '$customer';")
        employeeid=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
        "SELECT employee_id FROM employees WHERE employee_name = '$employee';")
        companyid=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
        "SELECT comp_id FROM company WHERE comp_id = '$company';")
            if [ $customerid -ge 0 ]
            then
                if [ $employeeid -ge 0 ]
                then
                    if [ $companyid -ge 0 ]
                    then
                    psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
                    "INSERT INTO orders (customer_id, employee_id, company_id, order_status) VALUES ('$customerid', '$employeeid', '$companyid', 'open') ;"
                    zenity --info --text="Új számla megnyitva!"
                    else
                    zenity --info --text="Nem létezik ilyen cég!"
                    new_order
                    fi
                else
                zenity --info --text="Nem létezik ilyen eladó!"
                new_order
                fi
            else
            zenity --info --text="Nem létezik ilyen vásárló!"
            new_order
            fi
    done <<< "$add"
    zenity --info \
    --text="Számla megkezdve!"
    else
    zenity --info \
    --text="Üres számla nem hozható létre!"
    fi
    listen
}

product_order() {
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
    ords=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "SELECT product_name, unit_price, category_name, units_in_stock FROM products LEFT JOIN categories \
    ON products.category_id = categories.category_id WHERE products.category_id = '$1'")
    else
    ords=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
    "SELECT product_name, unit_price, category_name, units_in_stock FROM orders LEFT JOIN categories \
    ON products.category_id = categories.category_id")
    fi
    while IFS='|' read -r namme price cat stock
    do
        ezlenne+="$price "
        idvar+="$namme|"
        cattvar+="$cat|"
        stockvar+="$stock|"
    done <<< "$ords"
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

product_order() {
    zenity --info --text="Itt lehet majd listázni a lezárt számlákat."
}

menu() {
    ans=$(zenity --list --title "Menü" --radiolist --column "ID" --column="Funkció" \
    1 'Új számla' \
    2 'Nyitott számlák' \
    3 'Lezárt számlák' )
    if [ "$ans" == "Új számla" ]
    then
    new_order
    elif [ "$ans" == "Nyitott számlák" ]
    then
    product_order
    elif [ "$ans" == "Lezárt számlák" ]
    then
    closed_orders
    else
    listen
    fi
}
