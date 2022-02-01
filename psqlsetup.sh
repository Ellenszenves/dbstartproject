#!/bin/bash
sudo apt-get update
sudo apt-get install -y postgresql
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