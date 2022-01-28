#!/bin/bash
sudo apt-get update
sudo apt-get install -y postgresql
sudo -u postgres psql -c "CREATE DATABASE shop"
sudo chmod 777 starter.sql
sudo -u postgres psql -d shop -a -f starter.sql
sudo -u postgres psql -c "CREATE ROLE test WITH SUPERUSER"
sudo -u postgres psql -c "ALTER USER test WITH PASSWORD 'test'"
sudo -u postgres psql -c "ALTER ROLE test WITH LOGIN"
#Config fájl helye:
#sudo -u postgres psql -c 'SHOW config_file'
sudo -u postgres sed -i "s/port = 5432/port = 15432/" /etc/postgresql/12/main/postgresql.conf
sudo -u postgres sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
sudo chmod 666 /etc/postgresql/12/main/pg_hba.conf
read -r -d '' remote << END
host    all             all              0.0.0.0/0                       md5
END
echo $remote >> /etc/postgresql/12/main/pg_hba.conf
read -r -d '' remote << END
host    all             all              ::/0                            md5
END
echo $remote >> /etc/postgresql/12/main/pg_hba.conf
host    all             all              ::/0                            md5
sudo systemctl restart postgresql