#!/bin/bash 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DB_DIR="$SCRIPT_DIR/DATA"
CURRENT_DB="" 


create_database() {
    read -p "Enter your database name: " db_name
    if [[ ! "$db_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo -e "wrong database name can't enclude specual chars "
        return
    fi
    
    if [ -d "$DB_DIR/$db_name" ]; then
        echo -e "already exist db with the same name :( "
    else
        mkdir -p "$DB_DIR/$db_name"
        echo -e "'$db_name' created successfully"
    fi
}

list_databases() {
    echo -e "Databases: "
    if [ -z "$(ls -A "$DB_DIR")" ]; then
        echo "No databases found."
    else
        for db in "$DB_DIR"/*; do
            echo "- $db"
        done
    fi
}



connect_database() {
    read -p "Enter database name : " db_name
    if [ -d "$DB_DIR/$db_name" ]; then
        CURRENT_DB="$db_name"
        echo -e "Connected to '$db_name' successfully "
        table_menu
    else
        echo -e "Database '$db_name' not exist."
    fi
}



drop_database() {
    read -p "Enter database name to drop: " db_name
    if [ -d "$DB_DIR/$db_name" ]; then
        rm -rf "$DB_DIR/$db_name"
        echo -e "Database '$db_name' dropped "
    else
        echo -e "Database '$db_name' does not exist."
    fi
}

