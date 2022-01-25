#!/bin/bash
#A telepítések után újra kell indítani a gépet!
dockerinstall() {
docact="$(docker --version | grep -o "Docker")"
if [ "$docact" == "Docker" ]
then
zenity --info --text="Docker már telepítve!"
else
sudo apt-get update
sudo apt-get install -y docker
sudo apt-get install -y docker-compose
sudo usermod -aG docker $USER
zenity --info --text="A telepítés befejeződött, kérem indítsa újra a számítógépet!"
fi
}

postgresql_install() {
posact="$(docker ps | grep -o "postgres")"
if [ "$posact" == "postgres" ]
then
zenity --info --text="PostgreSQL aktív"
else
zenity --question --text="PostgreSQL nem aktív! Telepítsek?" \
--ok-label="Igen" --cancel-label="Ne"
sudo chmod 777 starter.sql
docker-compose up -d
fi
db_act="$(docker exec dbstartproject_db_1 psql -t -U test -d shop -c "SELECT * FROM teszt")"
echo "$db_act"
if [ "$db_act" == " aaaaa" ]
then
zenity --info --text="Az adatbázis lekérdezhető!"
else
zenity --question --text="Az adatbázis nem elérhető! Telepítsek?" \
--ok-label="Igen" --cancel-label="Ne"
sudo chmod 777 starter.sql
docker-compose up -d
fi
psql_act="$(psql --version | grep -o "psql")"
if [ "$psql_act" == "psql" ]
then
zenity --info --text="PSQL kliens telepítve!"
else
zenity --question --text="PSQL kliens nincs telepítve! Telepítsem?" \
--ok-label="Igen" --cancel-label="Ne"
sudo apt-get update
sudo apt-get install -y postgresql
fi
}

setup() {
    zenity --info --text="Figyelem! Ezt a telepítést csak a kiszolgáló gépen kell elindítani!" \
    --width=300 --height=150
    ans=$(zenity --list --title="Telepítő" --radiolist --column="ID" --column="Funkció" \
    1 'Docker Telepítő' \
    2 'Adatbázis telepítő')
    if [ "$ans" == "Docker Telepítő" ]
    then
    dockerinstall
    elif [ "$ans" == "Adatbázis telepítő" ]
    then
    postgresql_install
    fi
}
setup