#!/bin/bash

mainScreen=true
dbsScreen=false
tablesScreen=false

# Main Screen 
function mainScreen {

        echo -e "\nBash Shell Scripting Project\n"
	
	while true
	do
		echo "1) Enter to Our Database"
		echo "2) Exit"
		read -p "Enter your choice: " choice

                case $choice in
                        1 )                     
                                if ! [[  -e `pwd`/DB ]]; then
                                        mkdir -p ./DB
                                fi 
                                cd ./DB/
                                mainScreen=false
                                dbsScreen=true
                                ;;
                        2 )
                                exit
                                ;;
                        * )
                                echo -e "\nInvalid entry\n"
                                ;;
                esac
                break
        done
}

# DBs Screen 
function createDb {
	
        echo Enter the name of the database please
        read dbname

	# db name exists
	if [[ -e $dbname ]]; then
		echo -e "\nThis database name is already used\n"
	        echo "Press any key"
                read

	# new DB
	elif [[ $dbname =~ ^[a-zA-Z] ]]; then
		mkdir -p "$dbname"
		cd "./$dbname" 
		echo -e "\nDatabase created sucessfully\n"
		dbsScreen=false
		tablesScreen=true
		echo "Press any key"
                read
		break
	
	# numbers or other special characters
	else
		echo -e "\nInvalid Entry\n"
		echo "Press any key"
                read
	fi
}

function useExistingDb {

        if [ $(ls -A | wc -l) -eq 0 ]; then
               echo "There are no databases here"
	       echo "Press any key"
	       read
     
	else
		echo -e "\nYour existing databases are:\n"
		ls -d *

		echo Enter the name of the database
		read db
			
		if [[ "$db" = '' ]]; then
 			echo -e "\nInvalid entry\n"			
			echo press any key
	         	read
			
		elif ! [[ -d "$db" ]]; then
			echo -e "\nThis database doesn't exist\n"
			echo press any key	
			read
	
		else
			cd "$db"
			dbsScreen=false
			tablesScreen=true
		fi
	fi	
}

# delete table
function deleteTable {
	echo Enter the name of the table to delete
	read dbtable
	
	# not exist
	if ! [[ -f "$dbtable" ]]; then
		echo -e "\nThis table doesn't exist\n"
		echo Press any key
		read

	# exists
	else
		rm "$dbtable"
		echo -e "\nTable deleted\n"
		echo Press any key
		read
	fi
}

# create tables' data
function createData {

                if [[ -f "$dbtable" ]]; then
			# num of cols
			while true; do
				echo -e "\nHow many columns you want?\n"
				read num_col
				if [[ "$num_col" =~ ^[1-9][0-9]* ]]; then
					break
				else
					echo -e "\nInvalid entry\n"
				fi
			done
			
			# pk name
			while $validData; do
				echo -e "\nEnter primary key name\n"
				read pk_name
				
				if [[ $pk_name = "" ]]; then
			        	echo -e "\nPrimary key couldn't be NULL\n"
				
				elif [[ $pk_name =~ ^[a-zA-Z] ]]; then
					echo -n "$pk_name" >> "$dbtable"
					echo -n "-" >> "$dbtable"
					break
				
				else
					echo -e "\nPrimary key can't start with numbers or special characters\n"
				fi
			done
			
			# pk dataType
			while true; do
				echo -e "\nEnter primary key datatype\n"
				select choice in "integer" "string"; do
					if [[ "$REPLY" = "1" || "$REPLY" = "2" ]]; then
						echo -n "$choice" >> "$dbtable"
						echo -n ":" >> "$dbtable"
					        break 2
					else
						echo -e "\nInvalid choice\n"
					fi
					break
				done
			done
			
			for (( i = 1; i < num_col; i++ )); do
				
				# field name
				while true; do
					echo -e "\nEnter field $[i+1] name\n"
					read field_name
				
					if [[ $field_name = "" ]]; then
						echo -e "\nInvalid entry, please enter a correct name\n"
					
					elif [[ $field_name =~ ^[a-zA-Z] ]]; then
						echo -n "$field_name" >> "$dbtable"
						echo -n "-" >> "$dbtable"
						break
					
					else
			 	        echo -e "\nField name can't start with numbers or special characters\n"
					fi
				done
				
				# field dataType
				while true; do
					echo -e "\nEnter field $[i+1] datatype\n"
					select choice in "integer" "string"; do
						if [[ "$REPLY" = "1" || "$REPLY" = "2" ]]; then
							echo -n "$choice" >> "$dbtable"
							
					         	# if last column
					        	if [[ i -eq $num_col-1 ]]; then
						 	        echo $'\n' >> "$dbtable"
					
					        	# next column
					        	else
						        	echo -n ":" >> "$dbtable"
						        fi

						        break 2

						else
							echo -e "\nInvalid choice\n"
				        	fi
						break
					done
				done
			done
	
		else
			echo -e "\nInvalid entry\n" 
			echo Press any key
			read
		fi		
}


# Create Table
function createTable {

		echo "Enter the name of the table: "
		read dbtable
	
		if [[ $dbtable = "" ]]; then
			echo -e "\nInvalid entry, please enter a correct name\n"
	
		elif [[ -e "$dbtable" ]]; then
			echo -e "\nThis table name exists\n"

		elif  [[ $dbtable =~ ^[a-zA-Z] ]]; then
			touch "$dbtable"
			createData;
		        echo -e "\nTable created successfully\n"

		else
			echo -e "\n Table name can't start with numbers or special characters\n"
		fi

		echo Press any key
                read
}


# Function to check if input matches the specified data type
check_data_type() {
    input_value=$1  # Input value
    data_type=$2    # Desired data type
 
    if [[ "$input_value" =~ ^[0-9] && "$data_type" == "integer" ]]; then
        retval=1
    elif [[ "$input_value" =~ ^[a-zA-Z] && "$data_type" == "string" ]]; then
        retval=1
    else
        retval=0
    fi

    return $retval
}

# insert data into table
function insertData {

	echo Enter the name of the table
	read dbtable
	
	if ! [[ -f "$dbtable" ]]; then
		echo "This table doesn't exist"
		echo Press any key
		read
	else
		insertingData=true
		while $insertingData ; do
			
			echo Enter primary key $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $1}') of type $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $2}')
                        mydatatype="$(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $2}')"
			read
			
			check_data_type "$REPLY" "$mydatatype"
			check_type=$?

			#=> print all records except first record
			pk_used=$(cut -d ':' -f1 "$dbtable" | awk '{if(NR != 1) print $0}' | grep -x -e "$REPLY")
		
			if [[ "$REPLY" == '' ]]; then
				echo "No entry!"
		
			elif [[ "$check_type" == 0 ]]; then
				echo "Entry invalid"
		
			#! if primary key exists
			elif ! [[ "$pk_used" == '' ]]; then
				echo "This primary key is already used"
	
			else
				echo -n "$REPLY" >> "$dbtable"
				echo -n ':' >> "$dbtable"
				
				# to get number of columns in table
				num_col=$(head -1 "$dbtable" | awk -F: '{print NF}')
			
				for (( i = 2; i <= num_col; i++ )); do
					inserting_other_data=true
					while $inserting_other_data ; do
					
		                        	field_name=$(head -1 "$dbtable" | cut -d ':' -f$i | awk -F "-" '{print $1}') 
   		                        	field_datatype=$(head -1 "$dbtable" | cut -d ':' -f$i | awk -F "-" '{print $2}')
		                         	echo "Enter $field_name of type $field_datatype"
						read
			
                                                check_data_type "$REPLY" "$field_datatype"
                                                check_type=$?
                                        
						# not matching datatype
						if [[ "$check_type" == 0 ]]; then
							echo "Entry invalid"
					
						else
							# if last column
							if [[ i -eq $num_col ]]; then
								echo "$REPLY" >> "$dbtable"
								inserting_other_data=false
								insertingData=false
								echo "Entry inserted successfully"
							else
							# next column
								echo -n "$REPLY": >> "$dbtable"
								inserting_other_data=false
							fi
						fi
					done
				done
			fi
		done
		echo Press any key
		read
	fi
}


function displayTable {
	
	echo Enter name of the table
	read dbtable
	
	if ! [[ -f "$dbtable" ]]; then
		echo -e "\nThis table doesn't exist\n"
		echo Press any key
		read
	else
		n_col=$(awk -F ':' 'NR==1 {print NF; exit}' $dbtable)
		
		for (( i = 1; i <= n_col; i++ )); do
         		echo -n "$(head -1 "$dbtable" | cut -d ':' -f$i | awk -F "-" '{print $1}')"
		
                        if ! [[ "$i" == "$n_col" ]]; then
				echo -n ":"
                         fi
                done

		echo -e "\n"
		sed '1d' $dbtable
		echo -e "\nPress any key\n"
                read
	fi
}

function listTables {

        if [ $(ls | wc -l) -eq 0 ]; then
               echo "There are no tables here"
        else
               echo "Your existing tables are:"
               ls
	fi

	echo -e "\nPress any key\n"
        read
}

function selectFromTable {

        echo Enter name of the table
        read dbtable

        if ! [[ -f "$dbtable" ]]; then
                echo -e "\nThis table doesn't exist\n"
                echo press any key
                read
        else
		echo Enter primary key $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $1}') of type $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $2}')
                read search_key
                  
		record=$(grep "^$search_key:" $dbtable)
                if ! [[ $record == '' ]]; then

                        n_col=$(awk -F ':' 'NR==1 {print NF; exit}' $dbtable)

                        for (( i = 1; i <= n_col; i++ )); do

                               echo -n "$(head -1 "$dbtable" | cut -d ':' -f$i | awk -F "-" '{print $1}')"

                               if ! [[ "$i" == "$n_col" ]]; then
                                       echo -n ":"
                               fi
                         done
                         
                         echo -e "\n$record"
		else
			echo -e "\nNot Found\n"
                fi

                echo Press any key
                read
        fi
}

function updateTable {
	
	echo Enter the name of the table
	read dbtable

	if ! [[ -f "$dbtable" ]]; then
		echo -e "\nThis table doesn't exist\n"
		echo press any key
		read
	else
                echo Enter primary key $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $1}') of type $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $2}')
		read
		
		recordNum=$(cut -d ':' -f1 "$dbtable" | sed '1d'| grep -x -n -e "$REPLY" | cut -d':' -f1)
		
		if [[ "$REPLY" == '' ]]; then
			echo -e "\nNo entry\n"
	
		elif [[ "$recordNum" = '' ]]; then
			echo -e "\nThis primary key doesn't exist\n"
	
		else
			let recordNum=$recordNum+1
			
			# to get number of columns in table
			num_col=$(head -1 "$dbtable" | awk -F: '{print NF}') 
			
			# to show the other values of record
			echo -e  "\nOther fields and values of this record:"
			for (( i = 2; i <= num_col; i++ )); do
			    echo $(head -1 $dbtable | cut -d ':' -f$i | awk -F "-" 'BEGIN { RS = ":" } {print $1}') of type $(head -1 "$dbtable" | cut -d ':' -f$i |awk -F "-" 'BEGIN { RS = ":" } {print $2}') : $(sed -n "${recordNum}p" "$dbtable" | cut -d: -f$i)
			done
		
			# to show the other fields' names of this record
			echo -e "\nRecord fields:"
			option=$(head -1 $dbtable | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}')
			echo "$option"
			getFieldName=true
			while $getFieldName; do
				echo Enter field name to update
				read
				
				if [[ "$REPLY" = '' ]]; then
					echo -e "\nInvalid entry\n"
				
				elif [[ $(echo "$option" | grep -x "$REPLY") = "" ]]; then
			          echo -e "No such field with the entered name, please enter a valid field name"
				
				else
				 fieldnum=$(head -1 "$dbtable" | awk 'BEGIN{ RS = ":"; FS = "-" } {print $1}'| grep -x -n "$REPLY" | cut -d: -f1)
				 updatingField=true
				 while $updatingField; do
				
				 # updating field's primary key
			  	 if [[ "$fieldnum" = 1 ]]; then
					 echo Enter primary key $(head -1 "$dbtable" | cut -d ':' -f1 |awk -F "-" 'BEGIN { RS = ":" } {print $1}') of type $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" 'BEGIN { RS = ":" } {print $2}') 
					read
					check_type=$(check_data_type "$REPLY" "$dbtable" 1)
					pk_used=$(cut -d ':' -f1 "$dbtable" | awk '{if(NR != 1) print $0}' | grep -x -e "$REPLY")
					if [[ "$REPLY" == '' ]]; then
					echo -e "\nNo entry\n"
					
					elif [[ "$check_type" == 0 ]]; then
					echo -e "\nEntry invalid\n"
					
					elif ! [[ "$pk_used" == '' ]]; then
					echo -e "\nThis primary key already used\n"
				
					else 
					awk -v fn="$fieldnum" -v rn="$recordNum" -v nv="$REPLY" 'BEGIN { FS = OFS = ":" } { if(NR == rn)	$fn = nv } 1' "$dbtable" > "$dbtable".new && rm "$dbtable" && mv "$dbtable".new "$dbtable"
					updatingField=false
					getFieldName=false
					fi
					
					else
					updatingField=true
					while $updatingField ; do
					echo Enter $(head -1 $dbtable | cut -d ':' -f$fieldnum |awk -F "-" 'BEGIN { RS = ":" } {print $1}') of type $(head -1 "$dbtable" | cut -d ':' -f$fieldnum |awk -F "-" 'BEGIN { RS = ":" } {print $2}') 
					read
					check_type=$(check_data_type "$REPLY" "$dbtable" "$fieldnum")
					
					if [[ "$check_type" == 0 ]]; then
					echo -e "\nEntry invalid\n"
		
					else
	 				awk -v fn="$fieldnum" -v rn="$recordNum" -v nv="$REPLY" 'BEGIN { FS = OFS = ":" } { if(NR == rn)	$fn = nv } 1' "$dbtable" > "$dbtable".new && rm "$dbtable" && mv "$dbtable".new "$dbtable"
					updatingField=false
					getFieldName=false
					fi
					done
		 			fi
					done
					echo -e "\nField updated successfully\n"
				fi
			done
		fi
		echo Press any key
		read
	fi
}

function deleteFromTable {

        echo Enter name of the table
        read dbtable

        if ! [[ -f "$dbtable" ]]; then
                echo -e "\nThis table doesn't exist\n"
                echo press any key
                read
        else
		echo Enter primary key $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $1}') of type $(head -1 "$dbtable" | cut -d ':' -f1 | awk -F "-" '{print $2}')
                read search_key
                  
		record=$(grep -v "^$search_key:" $dbtable)

                if [ "$record" != "$(cat $dbtable)" ]; then

                        echo "$record" > $dbtable  # Rewrite the file without the deleted record
                        echo "Record with ID $search_key deleted"
                else
                        echo "Record not found for primary key $search_key"
                fi

                echo press any key
                read
        fi
}


function dropDb {
	echo Enter the name of the database
		read db

		if [[ "$db" = '' ]]; then
			echo -e "\nInvalid entry\n"

		# db exists
		elif ! [[ -d "$db" ]]; then
			echo -e "\nThis database doesn't exist\n"

		else
			rm -rf "$db"
			echo -e "\nRemoved from your databases\n"
		fi

		echo press any key
		read
}

while true 
do
	# Main screen
	while $mainScreen
       	do
		clear
		mainScreen
	done

	# Database screen
        while $dbsScreen
        do
                clear
		select choice in "Create a new database" "Use existing Database" "Drop Database" "Back"
	       	do 
		case $REPLY in
			1 ) # Create a database
				createDb;
				;;
			2 ) # Use existing
				useExistingDb;
				;;
			3 ) # Drop Database
				dropDb;
				;;
			4 ) # Back
				cd ..
				mainScreen=true
				dbsScreen=false
				tablesScreen=false
				;;
			* )
				echo -e "\nNot one of the choices\n"
				;;
		esac
		break
		done    
        done

	#Tables Screen
	while $tablesScreen; do
                clear
                echo "Enter your choice: "

                select choice in "Create table" "Delete table" "Insert into table" "Delete from table" "Update table" "Select from table" "Display table" "List tables" "Back"; do
                        case $REPLY in
                                1 ) # create table
                                        createTable;
                                        ;;
                                2 ) # delete table
                                        deleteTable;
                                        ;;
                                3 ) # insert into table
                                       insertData;
                                        ;;
                                4 ) # delete from table
                                       deleteFromTable;
                                        ;;                                        
                                5 ) # update table
                                       updateTable;
                                        ;;                                      
                                6 ) # select from table
                                       selectFromTable;
                                        ;;
                                7 ) # display table
                                       displayTable;
                                        ;;
				8 ) # list tables
                                       listTables;
                                        ;;
                                9 ) # back
                                        cd ..
                                        mainScreen=false
                                        dbsScreen=true
                                        tablesScreen=false
                                        ;;
                                * )
                                        echo -e "\nInvalid entry!\n"
                                        ;;
                        esac
                        break
                done
        done
done


