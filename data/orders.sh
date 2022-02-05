#!/bin/bash
new_order() {
    add=$(zenity --forms --title="Új számla" \
    --add-entry="Vásárló neve" \
    --add-entry="Eladó neve" )
    if [ -n "$add" ]
    then
    while IFS='|' read -r customer employee
    do
        customerid=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
        "SELECT customer_id FROM customers WHERE company_name = '$customer';")
        employeeid=$(psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
        "SELECT employee_id FROM employees WHERE employee_name = '$employee';")
            if [ $customerid -ge 0 ]
            then
                if [ $employeeid -ge 0 ]
                then
                psql -t -h $IP_db -p 15432 -U $db_user -d $db_name -c \
                "INSERT INTO orders (customer_id, employee_id) VALUES ('$customerid', '$employeeid') ;"
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
    zenity --info --text="Itt lehet majd hozzáadni a termékeket a számlához."
}