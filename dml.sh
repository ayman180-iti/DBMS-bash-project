dml.sh
insert_into_table() {
    read -p "Enter table name: " table_name
    local table_file="$DB_DIR/$CURRENT_DB/$table_name"
    local meta_file="$DB_DIR/$CURRENT_DB/.$table_name.meta"
    
    if [ ! -f "$table_file" ]; then
        echo "No table with that name : $table_name"
        return
    fi
    
    local columns=()
    local col_names=()
    local col_types=()
    local primary_key=""
    local primary_key_index=-1
    
    while read -r line; do
        columns+=("$line")
        local col_name=$(echo "$line" | cut -d: -f1)
        local col_type=$(echo "$line" | cut -d: -f2)
        local col_constraint=$(echo "$line" | cut -d: -f3)
        
        col_names+=("$col_name")
        col_types+=("$col_type")
        
        if [ "$col_constraint" = "PRIMARY KEY" ]; then
            primary_key="$col_name"
            primary_key_index=$((${#col_names[@]} - 1))
        fi
    done < "$meta_file"
    
    local values=()
    for i in "${!col_names[@]}"; do
        while true; do
            read -p "ennter value for ${col_names[$i]} with type of  (${col_types[$i]}): " value
            
            if [ "${col_types[$i]}" = "int" ] && [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
                echo "wrong int value"
                continue
            fi
            
           if [ $i -eq $primary_key_index ]; then
                if grep -q "^$value|" "$table_file"; then
                    echo "Primary key value must be unique. This value already exists"
                    continue
                fi
            fi
            
            values+=("$value")
            break
        done
    done
    
    local record=$(IFS="|"; echo "${values[*]}")
    echo "$record" >> "$table_file"
    echo "inserted successfully"
}




select_from_table() {
    read -p "Enter table name: " table_name
    local table_file="$DB_DIR/$CURRENT_DB/$table_name"
    local meta_file="$DB_DIR/$CURRENT_DB/.$table_name.meta"
    
    if [ ! -f "$table_file" ]; then
        echo "No table with that name : $table_name"
        return
    fi
    
    local col_names=()
    while read -r line; do
        local col_name=$(echo "$line" | cut -d: -f1)
        col_names+=("$col_name")
    done < "$meta_file"
    
    echo "\nTable Data\n"
    
    echo "${col_names[@]} \n"
    
    while read -r line; do
        IFS='|' read -ra values <<< "$line"
        echo  "${values[@]}\n"
    done < "$table_file"
}




delete_from_table() {
    read -p "Enter table name: " table_name
    local table_file="$DB_DIR/$CURRENT_DB/$table_name"
    local meta_file="$DB_DIR/$CURRENT_DB/.$table_name.meta"
    
    if [ ! -f "$table_file" ]; then
        echo "No table with that name : $table_name"
        return
    fi
    
    local primary_key=""
    # local primary_key_index=-1
    
    while read -r line; do
        local col_name=$(echo "$line" | cut -d: -f1)
        local col_constraint=$(echo "$line" | cut -d: -f3)
        
        if [ "$col_constraint" = "PRIMARY KEY" ]; then
            primary_key="$col_name"
            # primary_key_index=$(($primary_key_index + 1))
            break
        fi
        # primary_key_index=$(($primary_key_index + 1))
    done < "$meta_file"
    
    if [ -z "$primary_key" ]; then
        echo "No primary key defined for this table"
        return
    fi
    
    read -p "Enter $primary_key value to delete: " value
    
    local temp_file="$DB_DIR/$CURRENT_DB/.$table_name.tmp"
    
    grep -wv ^$value  "$table_file"  > "$temp_file"
    
    local original_lines=$(wc -l < "$table_file")
    local new_lines=$(wc -l < "$temp_file")
    
    if [ $original_lines -eq $new_lines ]; then
        echo "No record found"
        rm -f "$temp_file"
    else
        mv "$temp_file" "$table_file"
        echo "deleted successfully"
    fi
}





update_table() {
    read -p "enter table name: " table_name
    local table_file="$DB_DIR/$CURRENT_DB/$table_name"
    local meta_file="$DB_DIR/$CURRENT_DB/.$table_name.meta"
    
    if [ ! -f "$table_file" ]; then
        echo "No table with that name : $table_name"
        return
    fi
    
    local col_names=()
    local col_types=()
    local primary_key=""
    local primary_key_index=-1
    
    while read -r line; do
        local col_name=$(echo "$line" | cut -d: -f1)
        local col_type=$(echo "$line" | cut -d: -f2)
        local col_constraint=$(echo "$line" | cut -d: -f3)
        
        col_names+=("$col_name")
        col_types+=("$col_type")
        
        if [ "$col_constraint" = "PRIMARY KEY" ]; then
            primary_key="$col_name"
            primary_key_index=$((${#col_names[@]} - 1))
        fi
    done < "$meta_file"
    
    if [ -z "$primary_key" ]; then
        echo "the table dosn't have primary key"
        return
    fi
    
    read -p "enter $primary_key value to update: " value
    
    local line_number=0
    local target_line=""
    local target_index=-1
    
    while read -r line; do
        IFS='|' read -ra values <<< "$line"
        if [ "${values[0]}" = "$value" ]; then
            target_line="$line"
            target_index=$line_number
            break
        fi
        line_number=$((line_number + 1))
    done < "$table_file"
    
    if [ $target_index -eq -1 ]; then
        echo "404 : No record found with this primary key"
        return
    fi
    
    echo "\nCurrent values:"
    for i in "${!col_names[@]}"; do
        IFS='|' read -ra values <<< "$target_line"
        echo "${col_names[$i]}: ${values[$i]}"
    done
    
    echo "\nEnter new values - press Enter to keep current value:"
    local new_values=()
    IFS='|' read -ra old_values <<< "$target_line"
    
    for i in "${!col_names[@]}"; do
        if [ $i -eq $primary_key_index ]; then
            echo "can't change primary key ${col_names[$i]} = ${old_values[$i]}"
            new_values+=("${old_values[$i]}")
            continue
        fi
        
        read -p "${col_names[$i]} (${col_types[$i]}): " new_value

        if [ -z "$new_value" ]; then
            new_values+=("${old_values[$i]}")
        else
            if [ "${col_types[$i]}" = "int" ] && [[ ! "$new_value" =~ ^-?[0-9]+$ ]]; then
                echo "Invalid int value"
                new_values+=("${old_values[$i]}")
            else
                new_values+=("$new_value")
            fi
        fi
    done
    
    local temp_file="$DB_DIR/$CURRENT_DB/.$table_name.tmp"
    
    line_number=0
    while read -r line; do
        if [ $line_number -eq $target_index ]; then
            echo $(IFS="|"; echo "${new_values[*]}") >> "$temp_file"
        else
            echo "$line" >> "$temp_file"
        fi
        line_number=$((line_number + 1))
    done < "$table_file"
    
    mv "$temp_file" "$table_file"
    echo "updated successfully"
}
