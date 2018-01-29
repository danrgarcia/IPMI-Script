# IPMI-Script
This tool was created to help with IPMI Commands. This script will pull information from DB1 as well as DB2 for information verification. It will also create a menu of IPMI options to shorten having to write them out fully.

You can either run the script with the bash shell interpreter by runnining 'sh menu.sh' or convert it to an executable using 'chmod +x menu.sh' and then run it with './menu.sh'

Once the script is executed it will ask for you to input the hostname of the server. If it is an BG1 server it will poll DB1 for the Asset Tag, RFID Tag, Serial Number, LOM MAC, & MAC 1. If it is a BG2 server it will poll DB1 as well as DB2 for the information. If any of the information mismatches between the two it will highlight it in red.

After retrieving the information it will attempt to ping the OOB port. It will then display whether it was successful or not. Then it will display a menu of IPMI options.

1 Turn on UID light 2 FRU Print 3 Sol Options 4 SDR Options 5 SEL options 6 Power options 7 Boot options 8 Set default bmc username/password 9 Change hosts q Exit menu

Some of the options will open another menu with more options. Any command that will reboot or power off the server will present you with a confirmation before executing. Using command 9 you can change what host you are pointing at and pressing ‘q’ will quit.


*** Some information has been redacted from the script for security reasons:
BG1 = placeholder for business group 1
BG2 = placeholder for business group 2
DB1 = database 1
DB2 = database 2
