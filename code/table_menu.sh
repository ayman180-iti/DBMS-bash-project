#!/bin/bash

source ddl.sh
source dml.sh

table_menu() {
    while true; do
        echo -e "Database: ${CURRENT_DB}"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Back to Main Menu"
        read -p "Enter your choice: " choice

        case $choice in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) 
		CURRENT_DB=""; 
		break ;;
            *) echo -e "Wring input try again" ;;
        esac
    done
}
