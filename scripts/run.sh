#!/bin/bash

# Initialize data directory
DATA_DIR=/data/postgres

# postgres directory
POSTGRES_DIR=/usr/lib/postgresql/9.4/bin

# Create postgres user
export POSTGRESQL_USER=postgres
/usr/sbin/adduser       --system       --group       --shell /bin/bash       --disabled-password       --home /home/${POSTGRESQL_USER} ${POSTGRESQL_USER}       --gecos "Dedicated pguser user"
touch /home/${POSTGRESQL_USER}/.bashrc
chown ${POSTGRESQL_USER}:${POSTGRESQL_USER} /home/${POSTGRESQL_USER}/.bashrc

# Update postgres configurations
if [ ! -f "$DATA_DIR"/postgresql.conf ]; then
    mkdir -p "$DATA_DIR"
    chown postgres:postgres "$DATA_DIR"

    sudo -i -u postgres $POSTGRES_DIR/initdb -E utf8 --locale en_US.UTF-8 -D "$DATA_DIR"
    sed -i -e"s/^#listen_addresses =.*$/listen_addresses = '*'/" $DATA_DIR/postgresql.conf
    echo  "shared_preload_libraries='pg_stat_statements'">> "$DATA_DIR"/postgresql.conf
    echo "host    all    all    0.0.0.0/0    md5" >> "$DATA_DIR"/pg_hba.conf

    mkdir -p "$DATA_DIR"/pg_log
fi

chown -R postgres:postgres "$DATA_DIR"
chmod -R 700 "$DATA_DIR"

# Initialize first run
if [[ -e /.firstrun ]]; then
    /scripts/first_run.sh
fi


# Start PostgreSQL
echo "Starting PostgreSQL..."
exec chpst sudo -i -u postgres $POSTGRES_DIR/postgres -D "$DATA_DIR"
