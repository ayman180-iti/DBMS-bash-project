create_table() {
    read -p "Enter table name: " table_name
    if [[ ! "$table_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo -e "Wring table name. can't include special chars"
        return
    fi
    
    local table_file="$DB_DIR/$CURRENT_DB/$table_name"
    local meta_file="$DB_DIR/$CURRENT_DB/.$table_name.meta"
    
    if [ -f "$table_file" ]; then
        echo -e "Table '$table_name' already exists "
        return
    fi
    
    
    echo "Enter columns information (format: column_name datatype [PRIMARY KEY] * optional)"
    echo "only Supported datatypes: int, str"
    echo "Enter '-1' when finished"
    
    local columns=()
    local primary_key=""
    local column_count=0
    
    while true; do
        read -p "Column $((column_count + 1)): " column_input
        if [ "$column_input" = "-1" ]; then
            break
        fi
        
        
        local col_name=$(echo "$column_input" | cut -d' ' -f1)
	local col_type=$(echo "$column_input" | cut -d' ' -f2)
	local col_constraint=$(echo "$column_input" | cut -d' ' -f3)
        
        if [ -z "$col_name" ] || [ -z "$col_type" ]; then
            echo -e "Wring input. write: column_name datatype [PRIMARY KEY] *optinal"
            continue
        fi
        
        if [ "$col_type" != "int" ] && [ "$col_type" != "str" ]; then
            echo -e "wrong input. use Only 'int' and 'str' as a type of the column"
            continue
        fi
        
        if [ "$col_constraint" = "PRIMARY" ]; then
            if [ -n "$primary_key" ]; then
                echo -e "wring, can't have two primary keys"
                continue
            fi
            primary_key="$col_name"
            col_constraint="PRIMARY KEY"
        else
            col_constraint=""
        fi
        
        columns+=("$col_name:$col_type:$col_constraint")
        column_count=$((column_count + 1))
    done
    
    if [ $column_count -eq 0 ]; then
        echo -e "can't make a table of 0 columns"
        return
    fi
    
    if [ -z "$primary_key" ]; then
        echo -e "No primary key specified"
    fi
    
    for col in "${columns[@]}"; do
	echo "$col" >> "$meta_file"
    done
    
    touch "$table_file"
    echo -e "Table '$table_name' created"
}






list_tables() {
    echo -e "tables in '$CURRENT_DB'"
#    local tables=($(find "$DB_DIR/$CURRENT_DB" -maxdepth 1 -type f -name "*.meta" | sed 's/.*\.//' | sed 's/\.meta//' | grep -v "^\\."))
    mapfile -t tables < <(ls -1 "$DB_DIR/$CURRENT_DB")
    
    if [ ${#tables[@]} -eq 0 ]; then
        echo "No tables found."
    else
        for table in "${tables[@]}"; do
            echo "- $table"
        done
    fi
}



drop_table() {
    read -p "Enter table name to drop: " table_name
    local table_file="$DB_DIR/$CURRENT_DB/$table_name"
    local meta_file="$DB_DIR/$CURRENT_DB/.$table_name.meta"
    
    if [ -f "$table_file" ]; then
        rm -f "$table_file" "$meta_file"
        echo -e "table '$table_name' dropped successfully"
    else
        echo -e "table '$table_name' does not exist"
    fi
}
