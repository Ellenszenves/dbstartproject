#!/bin/bash
#A telepítések után újra kell indítani a gépet!
server_install() {
    docact="$(systemctl status postgresql | grep -o "active")"
    if [ "$docact" == "active" ]
    then
    --zenity --info --text="PostgreSQL szerver már telepítve."
    else
    sudo apt-get update
    sudo apt-get install -y postgresql
    fi
    read -p "Adatbázis neve:" dataname
    sudo -u postgres psql -c "CREATE DATABASE $dataname"
    sudo chmod 777 starter.sql
    sudo -u postgres psql -d $dataname -a -f starter.sql
    read -p "PSQL felhasználó:" username
    sudo -u postgres psql -c "CREATE ROLE $username WITH SUPERUSER"
    read -p "PSQL jelszó:" psqlpass
    sudo -u postgres psql -c "ALTER USER $username WITH PASSWORD '$psqlpass'"
    sudo -u postgres psql -c "ALTER ROLE $username WITH LOGIN"
    #Config fájl helye:
    #sudo -u postgres psql -c 'SHOW config_file'
    sudo -u postgres sed -i "s/port = 5432/port = 15432/" /etc/postgresql/12/main/postgresql.conf
    sudo -u postgres sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
    sudo chmod 666 /etc/postgresql/12/main/pg_hba.conf
    sudo -u postgres sed -i "s/local   all             postgres                                peer/local   all             postgres                                md5/" /etc/postgresql/12/main/pg_hba.conf
    echo "host    all             all              0.0.0.0/0                       md5" >> /etc/postgresql/12/main/pg_hba.conf
    echo "host    all             all              ::/0                            md5" >> /etc/postgresql/12/main/pg_hba.conf
    echo "local all $username md5" >> /etc/postgresql/12/main/pg_hba.conf
    sudo systemctl restart postgresql
    #Még hozzá kell adni az adott felhasználót a pg_hba.conf-ba: local all test md5
    pg_is_there=$(ls -la /home/$USER | grep -o .pgpass )
            if [ "$pg_is_here" == ".pgpass" ]
            then
            echo 127.0.0.1:15432:$dataname:$username:$psqlpass > /home/$USER/.pgpass
            sudo chmod 600 /home/$USER/.pgpass
            sudo chown $USER:$USER /home/$USER/.pgpass
            export PGPASSFILE='/home/'$USER'/.pgpass'
            zenity --info --text="Telepítés kész!!"
            else
            touch /home/$USER/.pgpass
            echo 127.0.0.1:15432:$dataname:$username:$psqlpass > /home/$USER/.pgpass
            sudo chmod 600 /home/$USER/.pgpass
            sudo chown $USER:$USER /home/$USER/.pgpass
            export PGPASSFILE='/home/'$USER'/.pgpass'
            zenity --info --text="Telepítés kész!"
            fi
}

client_install() {
    cliact="$(systemctl status postgresql | grep -o "active")"
    if [ "$cliact" == "active" ]
    then
    sudo apt-get update
    sudo apt-get install -y postgresql-client
    zenity --info --text="A programban a kliens menüpontban tud belépni."
    else
    zenity --info --text="A kliens már telepítve van!"
    fi
}

setup() {
    ans=$(zenity --list --title="Telepítő" --radiolist --column="ID" --column="Funkció" \
    1 'Szerver telepítő' \
    2 'Kliens telepítő')
    if [ "$ans" == "Szerver telepítő" ]
    then
    server_install
    elif [ "$ans" == "Kliens telepítő" ]
    then
    client_install
    fi
}
setup