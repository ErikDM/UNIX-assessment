
#!/bin/bash

#Confirming the EUID as root. Will not be albe to run the script without root permission.
if [[ $EUID -ne 0 ]]; then
		echo ""
        echo "You must be root to run this script."
        echo ""
        exit 1
fi

clear

#Setting the color red in a variable for failed output.
RED="\033[1;31m"
NC="\033[0m"


PS3='Please select an option: '
options=("Send backup to <Backupserver>" "Create new crontab" "Find 777 permission files" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Send backup to <Backupserver>")
			
			#Asking for which file to transfer. The variable will be stored in "backupfile".
			echo ""
            echo "Which file(s) would you like transfer with rsync?"
            echo "Example: /var/aide"
            printf "Answer: "
            read -r backupfile

            #Shows the default location on the backup server. If it is not okay for the user, he/she will be prompted for another location.
            echo "The default location on the backup server is /backups/fileserver/backupscript/"
            printf "Is this okay? <Y/N>: "
            read -r answer1

            if [[ $answer1 == "Y" || $answer1 == "y" ]]; then
            	
            	if
            		#If the rsync transfer is completed, it will be displayed for the user.
            		rsync -av -delete -e ssh $backupfile studentserver03@172.24.7.202:/backups/fileserver/backupscript; then
            		echo ""
            		echo "Transfer successful."
            		echo ""
            		exit 1
            	
            	else
            		#Printing out in red if the transfer failed. The rsync command will however display the errors.
            		echo ""
            		printf "SSH transfer ${RED}failed.${NC} Please check your connection and/or path.\n"
            		echo ""
            		exit 1
            	fi

            else
            	#Asking for another location to store the backup if the user did not type "Y or y".
            	echo "Which directory would you like to transfer your backup to?: "
            	echo "Example: /backups/fileserver/"
            	printf "Answer: "
            	read -r answer2
            fi
            	#Displays the directory location on the backup server.
            	echo ""
            	echo "Transfering your backup to < studentserver03@172.24.7.202:$answer2 >"
            	echo ""

            	if
            		#If the rsync transfer is completed, it will be displayed for the user.
            		rsync -av -delete -e ssh $backupfile studentserver03@172.24.7.202:$answer2; then
            		echo""
            		echo "Transfer successful."
            		echo ""
            		exit 1
            	else
            		#Printing out in red if the transfer failed. The rsync command will however display the errors.
            		echo ""
            		printf "SSH transfer ${RED}failed.${NC} Please check your connection and/or path.\n"
            		echo ""

            	fi
            break
            ;;


            #A feature that will add a new crontab for the user.
        "Create new crontab")
			echo ""

			#Listing the timefunction of crontabs.
			echo "* * * * *"
			echo "- - - - -"
			echo "| | | | |"
			echo "| | | | ----- Day of week (0 - 7) (Sunday=0 or 7)"
			echo "| | | ------- Month (1 - 12)"
			echo "| ----------- Day of month (1 - 31)"
			echo "| ----------- Hour (0 - 23)"
			echo "------------- Minute (0 - 59)"
			
			echo ""
			#Asking for user input about the time schedule for the crontab.
			echo "Please specify how often the cron should run:"
			echo "Example: 30 20 * * *"
			printf "Answer: "
			read -r answer3
			echo ""
			#Asking for user input about which command to be executed by the new cron.
			echo "Which command would you like to be executed?"
			echo "Example: cp -r /home/* /Backup"
			printf "Answer: "
			read -r answer4

			#Echo'ing the time schedule and command specified by the user into a crontab. It will create a file "mycron", which is used to install before deleting it.
			echo "Applying cron: $answer3 $answer4"
			echo ""
			crontab -l > mycron
			echo "$answer3 $answer4" >> mycron
			#Shows "failed" in red if the cron was not able to install (wrong user input.)
			crontab mycron echo "Installation success." || printf "Installation ${RED}failed.${NC} Please check your crontab specification.\n" exit 1
			echo ""
			#Listing all the crons after installment. Not only the new cron, but everything.
			echo "Listing active crontabs:"
			crontab -l

            break
            ;;


            #A function which will find all 777 files and prompt for user action.
        "Find 777 permission files")
            echo "Finding all files with permission 777..."
         
         	#Storing all found 777 files in a variable.
            FILES=$(find ~/ -perm 777)

            	#Displaying all 777 files on the system.
            	echo "Following 777 persmission files were found:"
            	echo ""
            	echo "$FILES"
            	echo ""

            	#Prompting the user if he/she would like to delete the files.
            	printf "Would you like to delete them? <Y/N>: "
            	read -r answer5

            	if [[ $answer5 == "y" || $answer5 == "Y" ]]; then

            		#Deleting all found files.
            		rm -rf $FILES
            		echo ""
            		echo "All files have been deleted."
            		exit 1

            	else
            		
            		#Does not delete all found files.
            		echo ""
            		echo "No files have been deleted."
            		exit 1

            fi

            break
            ;;


        #Exiting the script.
        "Quit")
            break
            ;;

        #All other arguments rather than the options will not be valid. Will loop the script.
        *) echo Invalid argument;;
    esac
done