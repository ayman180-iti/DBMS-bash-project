#!/bin/bash

source table_menu.sh
source db_ddl.sh

main_menu() {
    while true; do
        echo -e "\nMain Menu:"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect to Database"
        echo "4. Drop Database"
        echo "5. Exit"
        read -p "Enter your choice: " choice

        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) echo "Goodbye!"; exit 0 ;;
            *) echo -e "invalid option. Please try again" ;;
        esac
    done
}

echo  "Welcome to Bash DBMS"
main_menu